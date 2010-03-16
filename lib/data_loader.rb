require 'nokogiri'
require 'htmlentities'

module ParlyTags; end
module ParlyTags::DataLoader
  
  DATA_DIR = File.expand_path(File.dirname(__FILE__) + '/../data')
  GEO_FILE = "#{DATA_DIR}/GB.txt"
  CONSTITUENCY_FILE = "#{DATA_DIR}/constituencies/2005_constituencies.xml"

  def load_all_data
    # Rails.logger.info !
    log = Logger.new(STDOUT)
    
    log << "loading place data"
    load_places
    log << "\nloaded place data"
    log << "\nloading constituency data"
    load_constituencies
    log << "\nloaded constituency data"
    load_search_data
  end
  
  def load_search_data
    log = Logger.new(STDOUT)
    
    Placetag.delete_all
    
    log << "\nloading edm data"
    load_edms
    log << "\nloaded edm data\nloading wms data"
    load_wms
    log << "\nloaded wms data\n"
    log << "\nloaded wms data\nloading written answers"
    load_written_answers
    log << "\nloaded written answers\n"
    load_westminster_hall_debates
    log << "\nloaded westminster hall debates\n"
    load_debates
    log << "\nloaded debates"
  end
  
  def load_places
    log = Logger.new(STDOUT)
    
    Place.delete_all
    
    file = File.open(GEO_FILE)
    file.each do |line|
      fields = line.split("\t")
      Place.create!(
        :geoname_id => fields[0],
        :name => fields[1],
        :ascii_name => fields[2],
        :alternate_names => fields[3],
        :lat => fields[4],
        :lng => fields[5],
        :feature_class => fields[6],
        :feature_code => fields[7],
        :country_code => fields[8],
        :cc2 => fields[9],
        :admin1_code => fields[10],
        :admin2_code => fields[11],
        :admin3_code => fields[12],
        :admin4_code => fields[13],
        :population => fields[14],
        :elevation => fields[15],
        :gtopo30 => fields[16],
        :timezone => fields[17],
        :last_modified => fields[18]
      )
      log << 'p'
    end
    log << "\n"
  end
  
  def load_constituencies
    log = Logger.new(STDOUT)
    Constituency.delete_all
    
    doc = Nokogiri::XML(open(CONSTITUENCY_FILE))
    doc.xpath('//constituency').each do |constituency|
      name = constituency.xpath("name/text()").to_s
      lat = constituency.xpath("centre_lat/text()").to_s
      lng = constituency.xpath("centre_lon/text()").to_s
      area = constituency.xpath("area/text()").to_s
      max_lat = constituency.xpath("max_lat/text()").to_s
      max_lng = constituency.xpath("max_lon/text()").to_s
      min_lat = constituency.xpath("min_lat/text()").to_s
      min_lng = constituency.xpath("min_lon/text()").to_s
      
      Constituency.create!(
        :name => name.gsub('&amp;', '&'),
        :lat => lat,
        :lng => lng,
        :area => area,
        :max_lat => max_lat,
        :min_lat => min_lat,
        :max_lng => max_lng,
        :min_lng => min_lng
      )
      
      log << 'c'
    end
    log << "\n"
  end
  
  def load_edms  
    log = Logger.new(STDOUT)
    
    #hash table for translating the edms.org.uk session format into the edmi session number
    edmi_sessions = {
      "2009-2010" => "903", 
      "2008-2009" => "899", 
      "2007-2008" => "891",
      "2006-2007" => "885",
      "2005-2006" => "875",
      "2004-2005" => "873",
      "2003-2004" => "682",
      "2002-2003" => "681",
      "2001-2002" => "680",
      "2000-2001" => "679",
      "1999-2000" => "703",
      "1998-1999" => "702",
      "1997-1998" => "701",
      "1996-1997" => "700",
      "1995-1996" => "699",
      "1994-1995" => "698",
      "1993-1994" => "697",
      "1992-1993" => "696",
      "1991-1992" => "695",
      "1990-1991" => "694",
      "1989-1990" => "693"
      }
    
    edms_files = Dir.glob(RAILS_ROOT + '/data/edms/*.xml')
    
    edms_files.each do |file|
      doc = Nokogiri::XML(open(file))
    
      doc.xpath('//motion').each do |motion|  
        log << "\nEDM - #{motion.xpath("number/text()").to_s} "
        
        edm_text   = motion.xpath("text/text()").to_s
        edm_id     = motion.xpath("id/text()").to_s
        edm_title  = motion.xpath("title/text()").to_s
        edm_number = motion.xpath("number/text()").to_s
        session_name = motion.xpath("session/text()").to_s
        
        proposed_date = motion.xpath("signatures/signature/date/text()").first.to_s
        
        # to get around invalid markup
        edm_text.gsub!('&#xC3;&#xBA;', '&pound;')
        
        item = Item.new (
          :url => "http://edmi.parliament.uk/EDMi/EDMDetails.aspx?EDMID=#{edm_id}&SESSION=#{edmi_sessions[session_name]}",
          :title => "#{edm_number} - #{edm_title}",
          :kind => 'Edm'
        )
        unless proposed_date.blank?
          item.created_at = proposed_date
          item.updated_at = proposed_date
        end
        log << "i"

        term_extractor = TermExtractor.new(edm_text)
        add_placetags(term_extractor.terms, item, log)

        unless item.placetags.empty?
          item.save
          log << "s"
        end
      end
      
      log << "\n"
    end
  end
  
  def load_written_answers
    parser = PublicwhipParser.new()
    
    files = Dir.glob(RAILS_ROOT + '/data/written-answers/*.xml')
    files.each do |file|
      parser.parse_file file, "Written Answer"
    end
  end
  
  def load_debates
    parser = PublicwhipParser.new()
    
    files = [RAILS_ROOT + '/data/debates/debates2010-02-09b.xml']
    files.each do |file|
      parser.parse_file file, "Hansard Debate"
    end
  end

  def load_westminster_hall_debates
    parser = PublicwhipParser.new()
    
    files = Dir.glob(RAILS_ROOT + '/data/westminster-hall/*.xml')
  
    files.each do |file|
      parser.parse_file file, "Westminster Hall Debate"
    end
  end

  def load_wms
    parser = PublicwhipParser.new()
    
    wms_files = Dir.glob(RAILS_ROOT + '/data/wms/*.xml')
  
    wms_files.each do |file|
      parser.parse_file file, "WMS"
    end
  end
  
  
  def delete_data_files
    `rm -rf "#{DATA_DIR}/*"`
  end
  
  private
    def add_placetags terms, item, log
      terms.each do |term|
        places = Place.find_all_by_ascii_name_or_alternate_names(term)
        places.each do |place|
          placetag = Placetag.find_by_geoname_id(place.geoname_id)
          if placetag.nil?
            placetag = Placetag.new(:name => term)
            county = place.county_name
            placetag.county = county if county
            country = place.country_name
            placetag.country = place.country_name if country
            placetag.place_id = place.id
            placetag.geoname_id = place.geoname_id
            placetag.save
            place.has_placetag = true
            place.save
          end
          unless item.placetags.include?(placetag)
            item.placetags << placetag
            log << "p"
          end
        end
      end
    end
end

require 'nokogiri'
require 'htmlentities'

module ParlyTags; end
module ParlyTags::DataLoader
  
  DATA_DIR = File.expand_path(File.dirname(__FILE__) + '/../data')
  EDMS_FILES = ["#{DATA_DIR}/edms/2009-2010.xml"] 
  WMS_FILES = Dir.glob("#{DATA_DIR}/wms/*.xml")
  GEO_FILE = "#{DATA_DIR}/GB.txt"
  CONSTITUENCY_FILE = "#{DATA_DIR}/constituencies.txt"

  def load_all_data
    # Rails.logger.info !
    log = Logger.new(STDOUT)
    
    log << "loading place data"
    load_places
    log << "\nloaded place data\nloading edm data"
    load_edms
    log << "\nloaded edm data\nloading wms data"
    load_wms
    log << "\nloaded wms data\n"
    log << "\nloaded wms data\nloading written answers"
    load_written_answers
    log << "\nloaded written answers\n"
    load_westminster_hall
    log << "\nloaded westminster hall debates"
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
    log << '\n'
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
    
    EDMS_FILES.each do |file|
      # TODO: check file actually exists!
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

        term_extractor = TextParser.new(edm_text)
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
    log = Logger.new(STDOUT)
    
    files = ["#{DATA_DIR}/written-answers/answers2010-02-10a.xml"]
    
    files.each do |file|
      doc = Nokogiri::XML(open(file))
      
      doc.xpath('//publicwhip/ques').each do |question|
        question_ref =  question.xpath('@id').to_s
        answer_ref = question_ref.gsub(".q", ".r")
        
        question_date = ""
        if question_ref =~ /(\d{4}-\d{2}-\d{2})/
          question_date = $1
        end
        
        question_text = question.inner_text
        question_url  = question.xpath('@url').to_s
        
        question_number = ""
        question_numbers = question.xpath('p/@qnum')
        question_numbers.each do |qnum|
          question_number += "[#{qnum.to_s}]"
        end
        question_number.gsub!("][", "], [")
        
        answer = doc.xpath("publicwhip/reply[@id='#{answer_ref}']")
        answer_text = answer.inner_text
        
        speaker = question.xpath('@speakername').to_s
        
        minor_heading = get_minor_heading(question)
        major_heading = get_major_heading(question)
        
        title = "#{major_heading} #{minor_heading} #{question_number} - #{speaker}"
        
        log << "\nWRA - #{question_number} "
        
        item = Item.new (
          :url => question_url,
          :title => title,
          :kind => 'Written Answer'
        )
        unless question_date.blank?
          item.created_at = question_date
          item.updated_at = question_date
        end
        log << "i"
        
        term_extractor = TextParser.new(question_text + " " + answer_text)
        add_placetags(term_extractor.terms, item, log)

        unless item.placetags.empty?
          item.save
          log << "s"
        end
      end
      log << "\n"
    end
  end

  def load_westminster_hall_debates
    log = Logger.new(STDOUT)
  
    files = ["#{DATA_DIR}/westminster-hall/westminster2010-02-10a.xml"]
  
    files.each do |file|
      log << "\n"
      log << File.basename(file)
      doc = Nokogiri::XML(open(file))
      doc.xpath('//speech').each do |speech|  
        debate_text   = speech.content
        debate_id     = speech.xpath('@id').to_s
        debate_speaker_name  = speech.xpath('@speakername')
        debate_url = speech.xpath('@url').to_s
        
        minor_heading = ""
        major_heading = ""
        
        debate_date = ""
        if debate_id =~ /(\d{4}\-\d{2}\-\d{2})/
          debate_date = $1
        end
        
        minor_heading = get_minor_heading(speech)
        major_heading = get_major_heading(speech)
        if minor_heading =~ /(\[.*in the Chair.*\])()/
          minor_heading = minor_heading.gsub($1,"").strip
          minor_heading = minor_heading.gsub("\n", "")
          minor_heading = HTMLEntities.new.encode(minor_heading, :decimal)
          minor_heading = minor_heading.gsub('&#8212;', "").strip
          minor_heading = minor_heading.gsub('&#9;', "").strip

        end
        
        debate_title = "Debate on #{minor_heading}".strip
        
        item = Item.find_by_title_and_kind_and_created_at(debate_title, 'Westminster Hall Debate', debate_date)
        unless item
          item = Item.new (
            :url => debate_url,
            :title => debate_title,
            :kind => 'Westminster Hall Debate'
          )
          unless debate_date.blank?
            item.created_at = debate_date
            item.updated_at = debate_date
          end
          log << "\ni"
        end
        
        term_extractor = TextParser.new(debate_text)
        add_placetags(term_extractor.terms, item, log)

        unless item.placetags.empty?
          item.save
          log << "s"
        end
      end
    end
  end

  def load_wms
    Item.delete_all("kind = 'WMS'")
    
    log = Logger.new(STDOUT)
  
    WMS_FILES.each do |file|
      log << "\n"
      log << File.basename(file)
      doc = Nokogiri::XML(open(file))
      doc.xpath('//speech').each do |speech|  
        log << "\n"

        wms_text   = speech.content
        wms_id     = speech.xpath('@id').to_s
        wms_speaker_name  = speech.xpath('@speakername')
        wms_speaker_office  = speech.xpath('@speakeroffice')
        wms_url = speech.xpath('@url').to_s
        
        minor_heading = ""
        major_heading = ""
        
        wms_date = ""
        if wms_id =~ /(\d{4}\-\d{2}\-\d{2})/
          wms_date = $1
        end
        
        minor_heading = get_minor_heading(speech)
        major_heading = get_major_heading(speech)
        
        item = Item.new (
          :url => wms_url,
          :title => "#{major_heading} #{minor_heading} - #{wms_speaker_name} - #{wms_speaker_office}".strip,
          :kind => 'WMS'
        )
        unless wms_date.blank?
          item.created_at = wms_date
          item.updated_at = wms_date
        end
        log << "i"
        
        term_extractor = TextParser.new(wms_text)
        add_placetags(term_extractor.terms, item, log)

        unless item.placetags.empty?
          item.save
          log << "s"
        end
      end
    end
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
    
    def get_minor_heading section
      last = section.previous_sibling
      while (last && last.to_s[0..13] != "<minor-heading" && last.to_s[0..10] != "<publicwhip")
        last = last.previous_sibling
      end
      if last.to_s[0..13] == "<minor-heading"
        return last.inner_text.strip
      end
    end
    
    def get_major_heading section
      last = section.previous_sibling
      while (last && last.to_s[0..13] != "<major-heading" && last.to_s[0..10] != "<publicwhip")
        last = last.previous_sibling
      end
      if last.to_s[0..13] == "<major-heading"
         return last.inner_text.strip
      end
    end
end

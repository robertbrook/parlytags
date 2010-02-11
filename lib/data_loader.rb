require 'nokogiri'

module ParlyTags; end
module ParlyTags::DataLoader
  
  DATA_DIR = File.expand_path(File.dirname(__FILE__) + '/../data')
  EDMS_FILES = ["#{DATA_DIR}/2009-2010.xml"] 
  WMS_FILES = Dir.glob("#{DATA_DIR}/wms/*.xml")
  GEO_FILE = "#{DATA_DIR}/GB.txt"
  CONSTITUENCY_FILE = "#{DATA_DIR}/constituencies.txt"

  def load_all_data
    
    log = Logger.new(STDOUT)
    
    log << "loading place data"
    load_places
    log << "\nloaded place data\nloading edm data"
    load_edms
    log << "\nloaded edm data\nloading wms data"
    load_wms
    log << "\nloaded wms data\nloading written answers"
    load_load_written_answers
    log << "\nloaded written answers\n"
    
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
        
        # to get around invalid markup
        edm_text.gsub!('&#xC3;&#xBA;', '&pound;')
        
        item = Item.new (
          :url => "http://edmi.parliament.uk/EDMi/EDMDetails.aspx?EDMID=#{edm_id}&SESSION=#{edmi_sessions[session_name]}",
          :title => "#{edm_number} - #{edm_title}",
          :kind => 'Edm'
        )
        log << "i"

        term_extractor = TextParser.new(edm_text)

        term_extractor.terms.each do |term|
          tag = Tag.find_or_create_by_name(term)
          item.tags << tag
          log << "t"
        end

        item.save
        log << "s"
        item.populate_placetags
        log << "p"
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
        
        title_date = ""
        if question_ref =~ /(\d{4})-(\d{2})-(\d{2})/
          title_date = "from #{$3}/#{$2}/#{$1}"
        end
        
        question_text   = question.inner_text
        question_number = question.xpath('p/@qnum').to_s
        question_url = question.xpath('@url').to_s
        
        answer = doc.xpath("publicwhip/reply[@id='#{answer_ref}']")
        answer_text = answer.inner_text
        
        title = "Written Answer #{question_number} #{title_date}".strip
        
        log << "\nWRA - #{question_number} "
        
        item = Item.new (
          :url => question_url,
          :title => title,
          :kind => 'Written Answer'
        )
        log << "i"
        
        term_extractor = TextParser.new(question_text + " " + answer_text)

        term_extractor.terms.each do |term|
          tag = Tag.find_or_create_by_name(term)
          item.tags << tag
          log << "t"
        end

        item.save
        log << "s"
        item.populate_placetags
        log << "p"
      end
      log << "\n"
    end
  end

  def load_wms
    Item.delete_all("kind = 'WMS'")
    
    log = Logger.new(STDOUT)
  
    WMS_FILES.each do |file|
      log << File.basename(file)
      log << "\n"
      doc = Nokogiri::XML(open(file))
      doc.xpath('//speech').each do |speech|  
        log << "\n"

              wms_text   = speech.content
              wms_id     = speech.xpath('@id')
              wms_speaker_name  = speech.xpath('@speakername')
              wms_speaker_office  = speech.xpath('@speakeroffice')
              wms_url = speech.xpath('@url').to_s
               
              item = Item.new (
                :url => wms_url,
                :title => "#{wms_speaker_name} - #{wms_speaker_office}",
                :kind => 'WMS',
                :text => wms_text.strip!.slice(0..255) + " ..."
              )
              log << "i"
              
              term_extractor = TextParser.new(wms_text)
                    
              term_extractor.terms.each do |term|
                tag = Tag.find_or_create_by_name(term)
                item.tags << tag
                log << "t" 
              end
      
              item.save
              log << "s"
              item.populate_placetags
              log << "p"
            end
            
            log << "\n"
    end
  end
end

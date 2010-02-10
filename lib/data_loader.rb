require 'nokogiri'

module ParlyTags; end
module ParlyTags::DataLoader
  
  DATA_DIR = File.expand_path(File.dirname(__FILE__) + '/../data')
  EDMS_FILES = ["#{DATA_DIR}/2009-2010.xml"]  
  GEO_FILE = "#{DATA_DIR}/GB.txt"

  def load_dummy_data
    puts "loading place data"
    load_places
    puts "loading edm data"
    load_edms
    puts "generating search data"
    create_edm_items
  end

  def load_places
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
    end
  end
  
  def load_edms
    
    log = Logger.new(STDOUT)
    
    Edm.delete_all
    Member.delete_all
    Signature.delete_all
    Session.delete_all
    
    EDMS_FILES.each do |file|
      
      # TODO: check file actually exists!
      doc = Nokogiri::XML(open(file))

      amendments = []
    
      doc.xpath('//motion').each do |motion|
        
        # make or find a Session
        session = Session.find_or_create_by_name(motion.xpath("session/text()").to_s)
        
        # create an Edm
        log << "\n#{motion.xpath("number/text()").to_s} "
        
        edm_text = motion.xpath("text/text()").to_s
        
        # to get around invalid markup
        edm_text.gsub!('&#xC3;&#xBA;', '&pound;')
        
        edm = Edm.new(:motion_xml_id => motion.xpath("id/text()").to_s,
                     :session_id => session.id,
                     :number => motion.xpath("number/text()").to_s,
                     :title => motion.xpath("title/text()").to_s,
                     :text => edm_text,
                     :signature_count => motion.xpath("signature_count/text()").to_s
                     )
        edm.save
        
        # store amendment edms in an array to deal with once we've finished loading        
        # (we can't do anything with them yet as the parent EDM may not exist at this point)  
        if edm.is_amendment?
          amendments << edm
        end
      
        # loop through the signatures, and for each one
        motion.xpath('signatures/signature').each do |signature|
          
          # make or find a Member
          member =  Member.find_or_create_by_name_and_member_xml_id(signature.xpath("mp/text()").to_s, signature.xpath("mp/@id").to_s)
        
          signature_date = signature.xpath("date/text()").to_s
          signature_type = signature.xpath("type/text()").to_s
        
          # make an appropriate sub-type of Signature and attach it to the Edm and the Session
          case signature_type
            when 'Proposed'
              new_signature = Proposer.new :date => signature_date, :member_id => member.id, :edm_id => edm.id, :session_id => session.id
              edm.proposers << new_signature
              session.proposers << new_signature
              log << 'p'
            when 'Seconded'
              new_signature = Seconder.new :date => signature_date, :member_id => member.id, :edm_id => edm.id, :session_id => session.id
              edm.seconders << new_signature
              session.seconders << new_signature
              log << '2nd'
            when 'Signed'
              new_signature = Signatory.new :date => signature_date, :member_id => member.id, :edm_id => edm.id, :session_id => session.id
              edm.signatories << new_signature
              session.signatories << new_signature
              log << 's'
            else
              raise "Unrecognised signature type: #{signature_type}"
          end
        end
      end
    
      amendments.each do |amendment|
        parts = amendment.number.split("A")
        log << parts
        amendment_number = parts.pop()
        amended_edm = parts.join("A")
        parent = Edm.find_by_number_and_session_id(amended_edm, amendment.session_id)
        
        if parent
          amendment.amendment_number = amendment_number
          amendment.parent_id = parent.id
          amendment.save!
        end
        log << "\n"
      end
    end  
  end
  
  def create_edm_items
    
    log = Logger.new(STDOUT)
    
    Item.delete_all
    log << "Deleted all Items\n"

    Edm.all.each do |edm|
      term_extractor = TextParser.new(edm.text)
      #tag_list = term_extractor.terms.join(",")
      
      item = Item.new (
        :url => "http://localhost:3000/#{edm.session_name}/edms/#{edm.number}",
        :title => "#{edm.number} - #{edm.title}",
        :text => edm.text,
        :kind => 'Edm'
      )
      log << "i"
      
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
  end
  
end

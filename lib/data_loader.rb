require 'nokogiri'

module ParlyTags; end
module ParlyTags::DataLoader

  DATA_DIR = File.expand_path(File.dirname(__FILE__) + '/../data')
  SAMPLE_EDMS_FILE = "#{DATA_DIR}/1996-1997.xml"

  def load_edms
    # check file actually exists!
    Edm.delete_all
    Member.delete_all
    Signature.delete_all
    
    doc = Nokogiri::XML(open(SAMPLE_EDMS_FILE))
    
    doc.xpath('//motion').each do |motion|
      
      # create an Edm
      puts "loading #{motion.xpath("number/text()").to_s}"   
      edm = Edm.create :motion_xml_id => motion.xpath("id/text()").to_s, 
                   :session=>motion.xpath("session/text()").to_s,
                   :number=>motion.xpath("number/text()").to_s,
                   :title=>motion.xpath("title/text()").to_s,
                   :text=>motion.xpath("text/text()").to_s,
                   :signature_count=>motion.xpath("signature_count/text()").to_s
      
      # loop through the signatures, and for each one
      motion.xpath('signatures/signature').each do |signature|
        
        # make or find a Member
        member =  Member.find_or_create_by_name_and_member_xml_id(signature.xpath("mp/text()").to_s, signature.xpath("mp/@id").to_s)
        
        signature_date = signature.xpath("date/text()").to_s
        signature_type = signature.xpath("type/text()").to_s
        
        # make an appropriate sub-type of Signature and attach it to the Edm
        puts " creating signature (#{signature_type})"
        case signature_type
          when 'Proposed'
            new_signature = Proposer.new :date => signature_date, :member_id => member.id, :edm_id => edm.id
            edm.proposers << new_signature
          when 'Seconded'
            new_signature = Seconder.new :date => signature_date, :member_id => member.id, :edm_id => edm.id
            edm.seconders << new_signature
          when 'Signed'
            new_signature = Signatory.new :date => signature_date, :member_id => member.id, :edm_id => edm.id
            edm.signatories << new_signature
          else
            raise "Unrecognised signature type: #{signature_type}"
        end
      end
    end
  end
end

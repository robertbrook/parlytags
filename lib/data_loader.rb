require 'nokogiri'

module ParlyTags; end
module ParlyTags::DataLoader

  DATA_DIR = File.expand_path(File.dirname(__FILE__) + '/../data')
  SAMPLE_EDMS_FILE = "#{DATA_DIR}/1996-1997.xml"

  def load_edms
    # check file actually exists!
    Edm.delete_all
    Proposer.delete_all
    Signatory.delete_all
    
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
      
      # create a Proposer
      puts "creating Proposer"
      Proposer.create :member_xml_id => motion.xpath("proposer/@id").to_s,
                      :name => motion.xpath("proposer/text()").to_s,
                      :edm_id => edm.id
      
      motion.xpath('signatures/signature').each do |signature|
        
        # make a Signatory, for each signature …
        puts "creating Signatory"
        signatory = Signatory.new :date => signature.xpath("date/text()").to_s,
                                  :signatory_type => signature.xpath("type/text()").to_s,
                                  :member_name => signature.xpath("mp/text()").to_s,
                                  :member_xml_id => signature.xpath("mp/@id").to_s
                             
        # … then attach the new Signatory to the Edm                          
        edm.signatories << signatory
      end
    end
  end
end

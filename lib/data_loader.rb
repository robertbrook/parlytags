require 'nokogiri'

module ParlyTags; end
module ParlyTags::DataLoader

  DATA_DIR = File.expand_path(File.dirname(__FILE__) + '/../data')
  SAMPLE_EDMS_FILE = "#{DATA_DIR}/1996-1997.xml"

  def load_edms
    # check file actually exists!
    Edm.delete_all
    
    doc = Nokogiri::XML(open(SAMPLE_EDMS_FILE))
    
    doc.xpath('//motion').each do |motion|        
        Edm.create :motion_xml_id=>motion.xpath("id/text()").to_s, 
                           :session=>motion.xpath("session/text()").to_s,
                           :number=>motion.xpath("number/text()").to_s,
                           :title=>motion.xpath("title/text()").to_s,
                           :text=>motion.xpath("text/text()").to_s,
                           :signature_count=>motion.xpath("signature_count/text()").to_s
        # p motion.xpath("number/text()")
        #        Edm.create(:number=>motion.xpath("number/text()").to_s)
    end

    # IO.foreach(CONSTITUENCY_FILE) do |line|
    #       constituency_id = line[0..2]
    #       constituency_name = line[3..(line.length-1)].strip
    #       Constituency.create :name=>constituency_name, :ons_id=>constituency_id
    #     end
  end

end

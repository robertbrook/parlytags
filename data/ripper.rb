require 'rubygems'
require 'nokogiri'

doc = Nokogiri::XML(open('1996-1997.xml'))

doc.xpath('//motion').each do |motion|
    p motion.xpath("number/text()")
end


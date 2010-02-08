class Item < ActiveRecord::Base
  has_and_belongs_to_many :tags
  
  class << self
    def find_all_by_tag tag_name
      if tag_name.is_a?(String)
        tag = Tag.find_by_name(tag_name)
        return tag.items if tag
      elsif tag_name.is_a?(Array)
        tag_list = %Q|'#{tag_name.join("','")}'|
        tags = Tag.find(:all, :conditions => "name in (#{tag_list})")
        unless tags.empty?
          items = []
          tags.each do |tag|
            tag.items.each do |item|
              items << item unless items.include?(item)
            end
          end
          return items
        end
      end
    end
  end
  
  def populate_placetags
    tags.each do |tag|
      places = Place.find_all_by_ascii_name_or_alternate_names(tag.name)
      unless places.empty?
        places.each do |place|
          placetag = Placetag.find_by_geoname_id(place.geoname_id)
          if placetag.nil?
            placetag = Placetag.new(:name => tag.name)
            county = place.county_name
            placetag.county = county if county
            country = place.country_name
            placetag.country = place.country_name if country
            placetag.place_id = place.id
            placetag.geoname_id = place.geoname_id
            tag.placetags << placetag
            tag.save
            place.has_placetag = true
            place.save
          end
        end
      end
    end
  end
    
end
class Item < ActiveRecord::Base
  is_taggable :tags, :geotags
  
  class << self
    def find_all_by_tag tag_name, tag_kind="tag"
      if tag_name.is_a?(String)
        tag = Tag.find_by_name_and_kind(tag_name, tag_kind)
        if tag
          tag_links = tag.taggings.find_all_by_taggable_type(self.name)
          if tag_links
            instance_ids = tag_links.collect { |x| x.taggable_id }
            return self.find(instance_ids)
          end
        end
      elsif tag_name.is_a?(Array)
        tag_list = %Q|'#{tag_name.join("','")}'|
        tags = Tag.find(:all, :conditions => "name in (#{tag_list}) AND kind='#{tag_kind}'")
        if tags
          instance_ids = []
          tags.each do |tag|
            tag_links = tag.taggings.find_all_by_taggable_type(self.name)
            if tag_links
              tag_ids = tag_links.collect { |x| x.taggable_id }
              instance_ids += tag_ids
            end
          end
          return self.find(instance_ids)
        end
      end
    end
  end
  
  def generate_geotags
    geotags = ""
    tag_list.each do |tag|
      places = Place.find_all_by_ascii_name_or_alternate_names(tag)
      place_list = places.collect { |x| "#{x.id}" }
      unless place_list.blank?
        if geotags.blank?
          geotags = place_list.join(',')
        else
          geotags = "#{geotags}, #{place_list.join(',')}"
        end
      end
    end
    self.geotag_list = geotags
    save!
    self.geotag_list
  end
  
  def place_names
    tags = geotag_list
    
    places = Place.find(tags)
    tags_list = places.collect { |x| x.alternate_names.split(",") }
    tags_list = tags_list.join(",").gsub(",,",",").split(",")
    tags_list += places.collect { |x| x.ascii_name }
  end
end
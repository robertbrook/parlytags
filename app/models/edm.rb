class Edm < ActiveRecord::Base
  has_many :motion_signatures
  has_many :proposers, :through => :motion_signatures, :source => :signature, :conditions => "type = 'Proposer'"
  has_many :seconders, :through => :motion_signatures, :source => :signature, :conditions => "type = 'Seconder'"
  has_many :signatories, :through => :motion_signatures, :source => :signature, :conditions => "type = 'Signatory'"
  belongs_to :session
  has_many :edm_amendments
  
  delegate :name, :to => :session, :prefix => :session
  
  acts_as_tree :order => "amendment_number"
  is_taggable :tags, :geotags
  
  class << self
    def amendment_format
      /(\d+)A(\d+)/
    end
    
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
  
  def signatories_and_seconders_count
    signatories.size + seconders.size
  end
  
  def seconders_count
    seconders.size
  end
  
  def has_proposer?
    proposers.size > 0
  end
  
  def is_amendment?
    if number =~ Edm.amendment_format
      true
    else
      false
    end
  end
    
end
class Place < ActiveRecord::Base
  acts_as_mappable :default_units => :kms
  has_one :placetag
  
  class << self
    def find_all_by_ascii_name_or_alternate_names(term)
      original_term = term
      term = term.gsub("'", "\'").strip
      places = find_all_by_name(term)
      if places.empty?
        places = find_all_by_ascii_name(term)
      end
      other_places = find(
        :all, 
        :conditions => "alternate_names = \'#{term.gsub("'", "\\\\'")}\' or alternate_names like \'#{term.gsub("'", "\\\\'")},%\' or alternate_names like \'%,#{term.gsub("'", "\\\\'")},%\' or alternate_names like \'%,#{term.gsub("'", "\\\\'")}\'"
        )
      other_places.each do |place|
        places << place unless places.include?(place)
      end
      if places.empty? && original_term.include?("'")
        term = original_term.gsub("'", "").strip
        find_all_by_ascii_name_or_alternate_names(term)
      end
      places
    end
  end
  
  def find_places_within_radius(distance, units = :kms)
    unless units == :miles
      units = :kms
    end
    Place.find(:all, :origin => self, :within => distance, :units => units)
  end
  
  def find_nearby_tagged_places(limit=10)
    Place.find(:all, :origin => self, :within => 40, :units => :kms, :conditions => {:feature_class => 'P', :has_placetag => true}, :order => 'distance', :limit => limit )
  end
  
  def find_nearby_items(limit=10)
    nearby_places = find_nearby_tagged_places
    items = []
    nearby_places.each do |place|
      place.placetag.tags.first.items.each do |item|
        items << item unless items.include?(item)
      end
      break if items.count >= limit
    end
    items[0..limit-1]
  end
end
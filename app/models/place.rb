class Place < ActiveRecord::Base
  
  class << self
    def find_all_by_ascii_name_or_alternate_names(term)
      term = term.gsub("'","\\'").strip
      places = find_all_by_ascii_name(term)
      if places.blank?
       places = find(:all, :conditions => "alternate_names like \'%#{term}%\'")
      end
      places
    end
  end
  
  def geotag
    Tag.find_by_name_and_kind(id, "geotag")
  end
  
  def nearby_tagged_places
    north_bound = long + 0.2
    south_bound = long - 0.2
    east_bound = lat + 0.25
    west_bound = lat - 0.25
        
    tags = Tag.find(:all, :conditions => {:kind => 'geotag'})
    geotags = tags.collect { |x| x.name }
    
    places = Place.find(
      :all, 
      :conditions => [
        "(lat between ? and ?) and (`long` between ? and ?) and id != ? and id in (?)", 
        west_bound, east_bound, south_bound, north_bound, id, geotags])
  end
end
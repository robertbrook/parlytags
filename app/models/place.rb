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
end
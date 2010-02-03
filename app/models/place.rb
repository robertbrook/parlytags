class Place < ActiveRecord::Base
  acts_as_mappable
  
  class << self
    def find_all_by_ascii_name_or_alternate_names(term)
      term = term.gsub("'", "\\\\'").strip
      places = find_all_by_ascii_name(term)
      other_places = find(
        :all, 
        :conditions => "alternate_names = \'#{term}\' or alternate_names like \'#{term},%\' or alternate_names like \'%,#{term},%\' or alternate_names like \'%,#{term}\'"
        )
      other_places.each do |place|
        places << place unless places.include?(place)
      end
      places
    end
  end
  
  def geotag
    Tag.find_by_name_and_kind(id, "geotag")
  end
end
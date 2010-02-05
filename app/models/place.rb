class Place < ActiveRecord::Base
  acts_as_mappable :default_units => :kms
  
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
  
  def geotag
    Tag.find_by_name_and_kind(id, "geotag")
  end
end
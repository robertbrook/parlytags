class Place < ActiveRecord::Base
  
  class << self
    def find_all_by_ascii_name_or_alternate_names(term)
      term = term.gsub("'","\\'")
      find(:all, :conditions => "ascii_name = '#{term}' or alternate_names='#{term}'")
    end
  end
  
  def geotag
    Tag.find_by_name_and_kind(id, "geotag")
  end
end
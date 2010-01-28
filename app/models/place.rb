class Place < ActiveRecord::Base
  
  def geotag
    Tag.find_by_name_and_kind(id, "geotag")
  end
end
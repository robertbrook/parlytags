class Constituency < ActiveRecord::Base
  acts_as_mappable :default_units => :kms
  has_and_belongs_to_many :items
  
  def zoom_level
    if area > 2000000000
      return 7
    else
      return 12
    end
  end
  
  def county_name
    nil
  end
  
  def ascii_name
    name
  end
  
  def display_name
    "Constituency of #{name}"
  end
  
  def alternative_places
    Place.find_all_by_ascii_name_or_alternate_names(name)
  end
end
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
  
  def alternative_places
    []
  end
end
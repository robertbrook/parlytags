class Placetag < ActiveRecord::Base
  has_and_belongs_to_many :items
  belongs_to :place
  
  def initialize place_name, place
    super()
    self.name = place_name
    self.county = place.county_name if place.county_name
    self.country = place.country_name if place.country_name
    self.place_id = place.id
    self.geoname_id = place.geoname_id
  end
end
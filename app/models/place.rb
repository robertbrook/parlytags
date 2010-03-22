class Place < ActiveRecord::Base
  acts_as_mappable :default_units => :kms
  has_one :placetag
  has_many :alternate_names
  
  class << self
    def find_all_by_ascii_name_or_alternate_names(term)
      original_term = term
      term = term.gsub("'", "\'").strip
      parts = term.split(" ")
      if parts.pop.downcase == "airport"
        place_name = parts.join(" ")
        places = find_all_by_name_and_feature_code(place_name, "AIRP")
      else
        places = find_all_by_name(term, :conditions => "feature_code != 'BNK' and feature_code != 'AIRP'", :order => "feature_class")
      end

      if places.empty?
        places = find_all_by_ascii_name(term, :conditions => "feature_code != 'BNK'", :order => "feature_class")
      end

      alternates = AlternateName.find_all_by_name(term)
      other_places = alternates.collect { |x| x.place }
      other_places.each do |place|
        if place
          unless places.include?(place) || place.feature_code == 'BNK'
            places << place
          end
        end
      end

      if places.empty? && original_term.include?("'")
        term = original_term.gsub("'", "").strip
        find_all_by_ascii_name_or_alternate_names(term)
      end
      places
    end
    
    def find_all_within_constituency(constituency)
      sw_point = GeoKit::LatLng.new(constituency.min_lat, constituency.min_lng)
      ne_point = GeoKit::LatLng.new(constituency.max_lat, constituency.max_lng)
      find :all, :bounds=>[sw_point,ne_point]
    end
  end
  
  def display_name
    if feature_code == "AIRP" && !(ascii_name =~ /[A|a]irport$/)
      return "#{ascii_name} Airport"
    end
    return ascii_name.gsub(/^County of /, "")
  end
  
  def county_name
    if ["AREA", "A", "ADM1", "ADM2", "ISL","ADMD", "PCLI"].include?(feature_code)
      return nil
    end
    county = nil
    counties = possible_counties
    if counties && counties.size > 0
      county = counties.first.ascii_name.gsub(/^County of /, "")
    end
    if (counties.nil? || counties.size == 0) && feature_code == "PPLX"
      city = find_nearest_city()
      county = city.ascii_name if city
    end
    return nil if county == ascii_name
    county
  end
  
  def country_name
    country = Place.find_by_feature_code_and_admin1_code("ADM1", admin1_code)
    return country.ascii_name if country
  end
  
  def alternative_places
    possible_places = Place.find_all_by_ascii_name_or_alternate_names(ascii_name)
    places = []
    possible_places.each do |place|
      unless place.id == self.id || 
          place.feature_code == "BNK" || place.feature_code == "SWT" ||
          (place.ascii_name == ascii_name && place.county_name.nil?) ||
          ((place.display_name.downcase == display_name.downcase) && (place.county_name.nil? || place.county_name == county_name))
        places << place
      end
    end
    constituency = Constituency.find_by_name(ascii_name)
    places << constituency if constituency
    places
  end
  
  def zoom_level
    case feature_code
      when "PPLC", "PPLA"
        13
      when "ADM2"
        9
      when "AREA", "A", "ADM1"
        6
      when "ISL"
        if name == "Ireland"
          6
        else
          10
        end
      when "ADMD"
        8
      when "PCLI"
        5
      when "MNMT", "MUS"
        17
      when "BAY"
        10
      else
        14
    end
    
  end
  
  def find_places_within_radius(distance, units = :kms)
    unless units == :miles
      units = :kms
    end
    Place.find(:all, :origin => self, :within => distance, :units => units)
  end
  
  def find_nearby_tagged_places(limit=10)
    places = [self]
    places += Place.find(:all, :origin => self, :within => 40, :units => :kms, :conditions => {:feature_class => 'P', :has_placetag => true}, :order => 'distance', :limit => limit )
  end
  
  def find_nearest_city
    place = Place.find(:all, :origin => self, :within => 5, :units => :kms, :conditions => {:feature_code => 'PPLC'}, :order => 'distance', :limit => 1 )
    place.first
  end
  
  def find_nearby_items(limit=10)
    nearby_places = find_nearby_tagged_places
    items = []
    nearby_places.each do |place|
      if place.placetag
        place.placetag.items.each do |item|
          items << item unless items.include?(item)
        end
      end
      break if items.count >= limit
    end
    items[0..limit-1]
  end
  
  private
    def possible_counties
      unless ["AREA", "A", "ADM1", "ISL"].include?(feature_code) || admin2_code.blank?
        counties = Place.find_all_by_feature_code_and_admin2_code_and_admin1_code("ADM2", admin2_code, admin1_code)
        if counties.size == 1
          return counties
        elsif counties.size > 1
          return counties.sort_by_distance_from(self)
        end
      end
    end
end
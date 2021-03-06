require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Place do
  
  describe 'when asked to find by ascii_name or alternate_names' do
        
    it 'should correctly escape the search term' do
      term = "Her Majesty's Opposition's"
      Place.should_receive(:find_all_by_ascii_name).with("Her Majesty\'s Opposition\'s", {:order => "feature_class", :conditions => "feature_code != 'BNK'"}).and_return([mock_model(Place)])
      
      Place.find_all_by_ascii_name_or_alternate_names(term)
    end
    
    it 'should find a matching place if the place name is stored without the apostrophe' do
      term = "King's Lynn"
      Place.should_receive(:find_all_by_ascii_name).with("King\'s Lynn", :conditions => "feature_code != 'BNK'", :order => "feature_class").and_return([])
      Place.should_receive(:find_all_by_ascii_name).with("Kings Lynn", {:order => "feature_class", :conditions => "feature_code != 'BNK'"}).and_return([mock_model(Place)])
      
      Place.find_all_by_ascii_name_or_alternate_names(term)
    end
    
    it 'should return a single result where there is a direct name match' do
      term = "Big Ben"
      place = mock_model(Place)
      Place.should_receive(:find).with(:all, :order => "feature_class", :conditions => {:name => 'Big Ben'}, :conditions => "feature_code != 'BNK' and feature_code != 'AIRP'").and_return([place])
      Place.should_not_receive(:find).with(:all, :order => "feature_class", :conditions => {:ascii_name => 'Big Ben'})
      AlternateName.should_receive(:find_all_by_name).with(term).and_return([])
      
      Place.find_all_by_ascii_name_or_alternate_names(term).should == [place]
    end
    
    it 'should return an airport match when the search term ends with "Airport"' do
      term = "Islay Airport"
      place = mock_model(Place)
      Place.should_receive(:find_all_by_name_and_feature_code).with("Islay", "AIRP").and_return([place])
      
      Place.find_all_by_ascii_name_or_alternate_names(term).should == [place]
    end
    
    it 'should return a single result where there is a direct ascii_name match' do
      term = "Big Ben"
      place = mock_model(Place)
      Place.should_receive(:find).with(:all, :order => "feature_class", :conditions => {:name => 'Big Ben'}, :conditions => "feature_code != 'BNK' and feature_code != 'AIRP'").and_return([])
      Place.should_receive(:find).with(:all, :order => "feature_class", :conditions => {:ascii_name => 'Big Ben'}, :conditions => "feature_code != 'BNK'").and_return([place])
      AlternateName.should_receive(:find_all_by_name).with(term).and_return([])
      
      Place.find_all_by_ascii_name_or_alternate_names(term).should == [place]
    end
    
    it 'should return a single result where there is one match within alternate_names' do
      term = "Essex"
      place = mock_model(Place, :name => 'County of Essex', :alternate_names => 'Essex', :feature_code => 'ADM2')
      altname = mock_model(AlternateName, :place => place)
      Place.should_receive(:find).with(:all, :order => "feature_class", :conditions => {:name => 'Essex'}, :conditions => "feature_code != 'BNK' and feature_code != 'AIRP'").and_return([])
      Place.should_receive(:find).with(:all, :order => "feature_class", :conditions => {:ascii_name => 'Essex'}, :conditions => "feature_code != 'BNK'").and_return([])
      AlternateName.should_receive(:find_all_by_name).with(term).and_return([altname])
      
      Place.find_all_by_ascii_name_or_alternate_names(term).should == [place]
    end
     
     it 'should return an array of results - where there are matches within name and alternate_name' do
       term = "Bedford"
       place1 = mock_model(Place, :feature_code => 'PPL')
       place2 = mock_model(Place, :feature_code => 'PPL')
       place3 = mock_model(Place, :feature_code => 'PPL')
       alt1 = mock_model(AlternateName, :place => place1)
       alt2 = mock_model(AlternateName, :place => place2)
       alt3 = mock_model(AlternateName, :place => place3)
       Place.should_receive(:find).with(:all, :order => "feature_class", :conditions => {:name => 'Bedford'}, :conditions => "feature_code != 'BNK' and feature_code != 'AIRP'").and_return([])
       Place.should_receive(:find).with(:all, :order => "feature_class", :conditions => {:ascii_name => 'Bedford'}, :conditions => "feature_code != 'BNK'").and_return([place1])
       AlternateName.should_receive(:find_all_by_name).with(term).and_return([alt2, alt1, alt3])

       Place.find_all_by_ascii_name_or_alternate_names(term).should == [place1, place2, place3]
     end
  end
  
  describe 'when asked to find nearby places within a given radius' do
    before do
      @place = Place.new()
    end
    
    it 'should pass the correct parameters to the finder and default to kms' do
      Place.should_receive(:find).with(:all, :origin => @place, :within => 5, :units => :kms)
      @place.find_places_within_radius(5)
    end
    
    it 'should change the units of distance to miles when passed :miles' do
      Place.should_receive(:find).with(:all, :origin => @place, :within => 15, :units => :miles)
      @place.find_places_within_radius(15, :miles)
    end
    
    it 'should default to using kms if anything other than miles is passed in' do
      Place.should_receive(:find).with(:all, :origin => @place, :within => 15, :units => :kms)
      @place.find_places_within_radius(15, :moo)
    end
  end
  
  describe 'when asked to find nearby tagged places' do
    before do
      @place = Place.new()
    end
    
    it 'should pass the correct parameters to the finder' do
      Place.should_receive(:find).with(:all, :origin => @place, :within => 40,:units => :kms, :conditions => {:feature_class => 'P', :has_placetag => true}, :order => 'distance', :limit => 10).and_return([])
      @place.find_nearby_tagged_places()
    end
    
    it 'should look limit the returned items to 50 if passed a limit of 50' do
      Place.should_receive(:find).with(:all, :origin => @place, :within => 40,:units => :kms, :conditions => {:feature_class => 'P', :has_placetag => true}, :order => 'distance', :limit => 50).and_return([])
      @place.find_nearby_tagged_places(50)
    end
  end
  
  describe 'when asked to find nearby items' do
    before do
      @place = Place.new()
      @item1 = mock_model(Item)
      @item2 = mock_model(Item)
      @item3 = mock_model(Item)
      @item4 = mock_model(Item)
      @item5 = mock_model(Item)
      @item6 = mock_model(Item)
      @item7 = mock_model(Item)
      @item8 = mock_model(Item)
      @item9 = mock_model(Item)
      @item10 = mock_model(Item)
      @item11 = mock_model(Item)
      @placetag1 = mock_model(Placetag, :items => [@item1, @item2])
      @placetag2 = mock_model(Placetag, :items => [@item3])
      @placetag3 = mock_model(Placetag, :items => [@item4, @item5])
      @placetag4 = mock_model(Placetag, :items => [@item6, @item7])
      @placetag5 = mock_model(Placetag, :items => [@item7])
      @placetag6 = mock_model(Placetag, :items => [@item8])
      @placetag7 = mock_model(Placetag, :items => [@item9])
      @placetag8 = mock_model(Placetag, :items => [@item10])
      @placetag9 = mock_model(Placetag, :items => [@item11])
      @place1 = mock_model(Place, :placetag => @placetag1)
      @place2 = mock_model(Place, :placetag => @placetag2)
      @place3 = mock_model(Place, :placetag => @placetag3)
      @place4 = mock_model(Place, :placetag => @placetag4)
      @place5 = mock_model(Place, :placetag => @placetag5)
      @place6 = mock_model(Place, :placetag => @placetag6)
      @place7 = mock_model(Place, :placetag => @placetag7)
      @place8 = mock_model(Place, :placetag => @placetag8)
      @place9 = mock_model(Place, :placetag => @placetag9)
    end
    
    it 'should return an array of items of 10 items using the default limit' do
      @place.should_receive(:find_nearby_tagged_places).and_return([@place1, @place2, @place3, @place4, @place5, @place6, @place7, @place8, @place9])
      @place.find_nearby_items.count.should == 10
    end
    
    it 'should return all items found if the limit is set higher than the total of found items' do
      @place.should_receive(:find_nearby_tagged_places).and_return([@place1, @place2, @place3, @place4, @place5, @place6, @place7, @place8, @place9])
      @place.find_nearby_items(14).count.should < 14
    end
    
    it 'should not include duplicate items' do
      @place.should_receive(:find_nearby_tagged_places).and_return([@place1, @place2, @place3, @place4, @place5, @place6, @place7, @place8, @place9])
      @place.find_nearby_items(14).count.should == 11
    end
    
    it 'should not continue looping through items once the required number have been found' do
      @place.should_receive(:find_nearby_tagged_places).and_return([@place1, @place2, @place3, @place4, @place5, @place6, @place7, @place8, @place9])
      @placetag1.should_receive(:items).and_return([@item1, @item2])
      @placetag2.should_receive(:items).and_return([@item3])
      @placetag3.should_receive(:items).and_return([@item4, @item5])
      @placetag4.should_not_receive(:items)
      
      @place.find_nearby_items(5).count.should == 5
    end
  end
  
  describe 'when asked for county_name' do
    before do
      @place = Place.new(:admin1_code => "ENG")
      @county1 = mock_model(Place, :ascii_name => "Hertfordshire")
      @county2 = mock_model(Place, :ascii_name => "Middlesex")
    end
    
    it 'should not provide a county name that is the same as the ascii_name' do
      @place.should_receive(:ascii_name).and_return("Hertfordshire")
      @place.stub!(:admin2_code).and_return("F8")
      Place.should_receive(:find_all_by_feature_code_and_admin2_code_and_admin1_code).with("ADM2", "F8", "ENG").and_return([@county1])
      
      @place.county_name.should == nil
    end
    
    it 'should not provide a county name for a country or an island' do
      @place.stub!(:feature_code).and_return('ADMD')
      @place.county_name.should == nil
      
      @place.stub!(:feature_code).and_return('ISL')
      @place.county_name.should == nil
    end
    
    it 'should return the name of the nearest county when there is an array of counties' do
      @place.stub!(:ascii_name).and_return("West Drayton")
      @place.stub!(:admin2_code).and_return("00")
      Place.should_receive(:find_all_by_feature_code_and_admin2_code_and_admin1_code).with("ADM2", "00", "ENG").and_return([@county1, @county2])
      @county1.should_receive(:distance_to).with(@place, {}).and_return(220)
      @county1.should_receive(:distance=).with(220)
      @county1.should_receive(:distance).and_return(220)
      @county2.should_receive(:distance_to).with(@place, {}).and_return(22)
      @county2.should_receive(:distance=).with(22)
      @county2.should_receive(:distance).and_return(22)
      
      @place.county_name.should == "Middlesex"
    end
  
    it 'should return the name of the county when there is only one county' do
      @place.stub!(:ascii_name).and_return("Cheshunt")
      @place.stub!(:admin2_code).and_return("F8")
      Place.should_receive(:find_all_by_feature_code_and_admin2_code_and_admin1_code).with("ADM2", "F8", "ENG").and_return([@county1])
    
      @place.county_name.should == "Hertfordshire"
    end
    
    it 'should return the nearest city for a suburb' do
      @place.stub!(:feature_code).and_return('PPLX')
      Place.should_receive(:find).with(:all, :origin => @place, :within => 5, :units => :kms, :conditions => {:feature_code => 'PPLC'}, :order => 'distance', :limit => 1).and_return([mock_model(Place, :ascii_name => "London")])
      
      @place.county_name.should == "London"
    end
  end
  
  describe 'when asked for country' do
    before do
      @place = Place.new(:admin1_code => 'ENG')
    end
    
    it 'should return a country name where there is a valid matching country record' do
      Place.should_receive(:find_by_feature_code_and_admin1_code).with("ADM1", "ENG").and_return(mock_model(Place, :ascii_name => "England"))
      @place.country_name.should == "England"
    end
    
    it 'should return nil where there is no matching country record' do
      Place.should_receive(:find_by_feature_code_and_admin1_code).with("ADM1", "ENG").and_return(nil)
      @place.country_name.should == nil
    end
  end

  describe 'when asked for display_name' do
    it 'should remove "County of " from the start of the name' do
      place = Place.new(:ascii_name => 'County of Essex', :feature_code => 'PPL')
      place.display_name.should == "Essex"
    end
    
    it 'should not remove "County of " from the middle of the name' do
      place = Place.new(:ascii_name => 'City and County of Cardiff', :feature_code => 'PPL')
      place.display_name.should == "City and County of Cardiff"
    end
    
    it 'should append " Airport" to the name if the place is an airport' do
      place = Place.new(:ascii_name => 'Islay', :feature_code => 'AIRP')
      place.display_name.should == "Islay Airport"
    end
    
    it 'should not append " Airport" if the name already ends with " Airport"' do
      place = Place.new(:ascii_name => 'Luton Airport', :feature_code => 'AIRP')
      place.display_name.should == "Luton Airport"
    end
  end
  
  describe 'when asked for alternative_places' do
    before do
      @place = Place.new(:ascii_name => "Sudbury", :id => 4)
      @place.stub!(:county_name => "Suffolk", :feature_code => "PPL")
      @place.stub!(:display_name => "Sudbury (Suffolk)")
      
      @alt_place1 = mock_model(Place, :ascii_name => "Sudbury", :feature_code => "PPL")
      @alt_place1.stub!(:county_name => "Staffordshire")
      @alt_place1.stub!(:display_name => "Sudbury (Staffordshire)")
      
      @alt_place2 = mock_model(Place, :ascii_name => "Sudbury", :feature_code => "PPL")
      @alt_place2.stub!(:county_name => "Greater London")
      @alt_place2.stub!(:display_name => "Sudbury (Greater London)")
      
      @alt_place3 = mock_model(Place, :ascii_name => "Sudbury Bank", :feature_code => "BNK")
      @alt_place3.stub!(:county_name => "Greater London")
      
      @alt_place4 = mock_model(Place, :ascii_name => "Sudbury", :feature_code => "PPL")
      @alt_place4.stub!(:county_name => "Suffolk")
      @alt_place4.stub!(:display_name => "Sudbury (Suffolk)")
      
      @alt_place5 = mock_model(Place, :ascii_name => "Sudbury", :feature_code => "PPL")
      @alt_place5.stub!(:display_name => "Sudbury")
      @alt_place5.stub!(:county_name => nil)
      
      @alt_place6 = mock_model(Place, :ascii_name => "Sudbury End", :feature_code => "PPL")
      @alt_place6.stub!(:county_name => "Suffolk")
      @alt_place6.stub!(:display_name => "Sudbury End (Suffolk)")
    end
    
    it 'should return an empty array where no alternative places are found' do
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("Sudbury").and_return([])
      Constituency.should_receive(:find_by_name).with("Sudbury").and_return(nil)
      @place.alternative_places.should == []
    end
    
    it 'should return a list of places where valid alternative places are found' do
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("Sudbury").and_return([@alt_place1, @alt_place2])
      Constituency.should_receive(:find_by_name).with("Sudbury").and_return(nil)
      @place.alternative_places.should == [@alt_place1, @alt_place2]
    end
    
    it 'should not include itself in the list' do
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("Sudbury").and_return([@alt_place1, @alt_place2, @place])
      Constituency.should_receive(:find_by_name).with("Sudbury").and_return(nil)
      @place.alternative_places.should == [@alt_place1, @alt_place2]
    end
    
    it 'should not include sandbanks in the list' do
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("Sudbury").and_return([@alt_place1, @alt_place2, @alt_place3])
      Constituency.should_receive(:find_by_name).with("Sudbury").and_return(nil)
      @place.alternative_places.should == [@alt_place1, @alt_place2]
    end
    
    it 'should not include places with the same display name and county in the list' do
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("Sudbury").and_return([@alt_place1, @alt_place2, @alt_place4])
      Constituency.should_receive(:find_by_name).with("Sudbury").and_return(nil)
      @place.alternative_places.should == [@alt_place1, @alt_place2]
    end
    
    it 'should not include places that have a matching ascii_name but not county name' do
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("Sudbury").and_return([@alt_place1, @alt_place2, @alt_place5])
      Constituency.should_receive(:find_by_name).with("Sudbury").and_return(nil)
      @place.alternative_places.should == [@alt_place1, @alt_place2]
    end
    
    it 'should include places from the same county that have a different display name' do
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("Sudbury").and_return([@alt_place1, @alt_place2, @alt_place6])
      Constituency.should_receive(:find_by_name).with("Sudbury").and_return(nil)
      @place.alternative_places.should == [@alt_place1, @alt_place2, @alt_place6]
    end
    
    it 'should include a matching constituency if there is one' do
      constituency = mock_model(Constituency)
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("Sudbury").and_return([@alt_place1, @alt_place2])
      Constituency.should_receive(:find_by_name).with("Sudbury").and_return(constituency)
      @place.alternative_places.should == [@alt_place1, @alt_place2, constituency]
    end
  end
  
  describe 'when asked to find all places within a constituency' do
    it 'should return an array of constituencies which fall within the passed constituency\'s bounding box' do
      constituency = mock_model(Constituency, :min_lat => 53.9726, :min_lng => -2.9833, :max_lat => 54.2396, :max_lng => -2.45881)
      place1 = mock_model(Place)
      place2 = mock_model(Place)
      geo1 = mock_model(GeoKit::LatLng)
      geo2 = mock_model(GeoKit::LatLng)
      GeoKit::LatLng.should_receive(:new).with(constituency.min_lat, constituency.min_lng).and_return(geo1)
      GeoKit::LatLng.should_receive(:new).with(constituency.max_lat, constituency.max_lng).and_return(geo2)
      Place.should_receive(:find).with(:all, :bounds => [geo1, geo2]).and_return([place1, place2])
      
      Place.find_all_within_constituency(constituency).should == [place1, place2]
    end
  end

  describe 'when asked for zoom level' do
    it 'should return 13 when place is a major city' do
      @place = Place.new(:feature_code => 'PPLC')
      @place.zoom_level.should == 13
    end
    
    it 'should return 17 when place is a monument' do
      @place = Place.new(:feature_code => 'MNMT')
      @place.zoom_level.should == 17
    end
    
    it 'should return 10 when place is an island' do
      @place = Place.new(:feature_code => 'ISL', :name => 'Orkney')
      @place.zoom_level.should == 10
    end
    
    it 'should return 6 when place a country' do
      @place = Place.new(:feature_code => 'ISL', :name => 'Ireland')
      @place.zoom_level.should == 6
      
      @place = Place.new(:feature_code => 'AREA')
      @place.zoom_level.should == 6
    end
    
    it 'should return 10 when place is a bay' do
      @place = Place.new(:feature_code => 'BAY')
      @place.zoom_level.should == 10
    end
    
    it 'should return 5 when place is a kingdom' do
      @place = Place.new(:feature_code => 'PCLI')
      @place.zoom_level.should == 5
    end
    
    it 'should return 8 when placed is a county' do
      @place = Place.new(:feature_code => 'ADMD')
      @place.zoom_level.should == 8
    end
    
    it 'should return 9 when place is a borough' do
      @place = Place.new(:feature_code => 'ADM2')
      @place.zoom_level.should == 9
    end
    
    it 'should return a default value of 14 if the feature_code is not recognised' do
      @place = Place.new(:feature_code => 'XXX')
      @place.zoom_level.should == 14
    end
  end
end
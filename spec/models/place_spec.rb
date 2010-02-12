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
      Place.should_receive(:find).with(:all, :order => "feature_class", :conditions => {:name => 'Big Ben'}, :conditions => "feature_code != 'BNK'").and_return([place])
      Place.should_not_receive(:find).with(:all, :order => "feature_class", :conditions => {:ascii_name => 'Big Ben'})
      Place.should_receive(:find).with(:all, :order => "feature_class", :conditions => "feature_code != 'BNK' and (alternate_names = 'Big Ben' or alternate_names like 'Big Ben,%' or alternate_names like '%,Big Ben,%' or alternate_names like '%,Big Ben')").and_return([])
      
      Place.find_all_by_ascii_name_or_alternate_names(term).should == [place]
    end
    
    it 'should return a single result where there is a direct ascii_name match' do
      term = "Big Ben"
      place = mock_model(Place)
      Place.should_receive(:find).with(:all, :order => "feature_class", :conditions => {:name => 'Big Ben'}, :conditions => "feature_code != 'BNK'").and_return([])
      Place.should_receive(:find).with(:all, :order => "feature_class", :conditions => {:ascii_name => 'Big Ben'}, :conditions => "feature_code != 'BNK'").and_return([place])
      Place.should_receive(:find).with(:all, :order => "feature_class", :conditions => "feature_code != 'BNK' and (alternate_names = 'Big Ben' or alternate_names like 'Big Ben,%' or alternate_names like '%,Big Ben,%' or alternate_names like '%,Big Ben')").and_return []
      
      Place.find_all_by_ascii_name_or_alternate_names(term).should == [place]
    end
    
    it 'should return a single result where there is one match within alternate_names' do
      term = "Essex"
      place = mock_model(Place, :name => 'County of Essex', :alternate_names => 'Essex', :feature_code => 'ADM2')
      Place.should_receive(:find).with(:all, :order => "feature_class", :conditions => {:name => 'Essex'}, :conditions => "feature_code != 'BNK'").and_return([])
      Place.should_receive(:find).with(:all, :order => "feature_class", :conditions => {:ascii_name => 'Essex'}, :conditions => "feature_code != 'BNK'").and_return([])
      Place.should_receive(:find).with(:all, :order => "feature_class", :conditions => "feature_code != 'BNK' and (alternate_names = 'Essex' or alternate_names like 'Essex,%' or alternate_names like '%,Essex,%' or alternate_names like '%,Essex')").and_return [place]
      
      Place.find_all_by_ascii_name_or_alternate_names(term).should == [place]
    end
     
     it 'should return an array of results - where there are matches within name and alternate_name' do
       term = "Bedford"
       place1 = mock_model(Place, :feature_code => 'PPL')
       place2 = mock_model(Place, :feature_code => 'PPL')
       place3 = mock_model(Place, :feature_code => 'PPL')
       Place.should_receive(:find).with(:all, :order => "feature_class", :conditions => {:name => 'Bedford'}, :conditions => "feature_code != 'BNK'").and_return([])
       Place.should_receive(:find).with(:all, :order => "feature_class", :conditions => {:ascii_name => 'Bedford'}, :conditions => "feature_code != 'BNK'").and_return([place1])
       Place.should_receive(:find).with(:all, :order => "feature_class", :conditions => "feature_code != 'BNK' and (alternate_names = 'Bedford' or alternate_names like 'Bedford,%' or alternate_names like '%,Bedford,%' or alternate_names like '%,Bedford')").and_return [place2, place1, place3]

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
  
  describe 'when asked for county' do
    before do
      @place = Place.new(:admin1_code => "ENG")
      @county1 = mock_model(Place, :ascii_name => "Hertfordshire")
      @county2 = mock_model(Place, :ascii_name => "Middlesex")
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
end
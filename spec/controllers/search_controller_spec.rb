require File.dirname(__FILE__) + '/../spec_helper'

describe SearchController do
  describe "when asked for index with no search parameters" do
    it 'should render the index page without performing a search' do
      Place.should_not_receive(:find_all_by_ascii_name_or_alternate_names)
      Constituency.should_not_receive(:find_by_name)
      
      get :index
      assigns[:results].should be_nil
      assigns[:last_search_term].should be_nil
      response.should be_success
    end
  end
  
  describe "when asked for index with a search parameter" do
    before do
      @placetag1 = mock_model(Placetag)
      @placetag1.stub!(:county)
      
      @constituency = mock_model(Constituency, 
                                  :min_lat => 53.9726, 
                                  :min_lng => -2.9833, 
                                  :max_lat => 54.2396, 
                                  :max_lng => -2.45881, 
                                  :name => 'London', 
                                  :lat => 51.5084, 
                                  :lng => -0.125533, 
                                  :zoom_level => 7)
      
      @item1 = mock_model(Item)
      @item2 = mock_model(Item)
      @item3 = mock_model(Item)
      @item4 = mock_model(Item)
      
      @place1 = mock_model(Place, :lat => 51.5084, :lng => -0.125533, :zoom_level => 7)
      @place1.stub!(:display_name).and_return('London')
      @place1.stub!(:placetag).and_return(@placetag1)
    end
    
    it 'should perform a search' do
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).exactly(2).times.with('London').and_return([])
      Constituency.should_receive(:find_by_name).with('London')
      
      get :index, :q => 'London'
      assigns[:last_search_term].should == 'London'
      assigns[:results].should be_nil
      response.should be_success
    end
    
    it 'should return results when there is a matching place' do
      @place1.stub!(:find_nearby_items).and_return([@item1, @item2, @item3, @item4])
      Constituency.should_receive(:find_by_name).with('London')
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with('London').and_return([@place1])
      
      get :index, :q => 'London'
      assigns[:last_search_term].should == 'London'
      assigns[:results].should == [@item1, @item2, @item3, @item4]
      assigns[:place].should == @place1
      assigns[:map].should_not be_nil
    end
    
    it 'should return results when there is a matching constituency' do
      Constituency.should_receive(:find_by_name).with('London').and_return(@constituency)
      Item.should_receive(:find_all_within_constituency).with(@constituency).and_return([@item1, @item2, @item3, @item4])
      
      get :index, :q => 'London'
      assigns[:last_search_term].should == 'London'
      assigns[:results].should == [@item1, @item2, @item3, @item4]
      assigns[:place].should == @constituency
      assigns[:map].should_not be_nil
    end
    
    it 'should not perform a place search if passed the parameter t = c' do
      Constituency.should_receive(:find_by_name).with('London')
      Place.should_not_receive(:find_all_by_ascii_name_or_alternate_names)
      
      get :index, :q => 'London', :t => 'c'
    end
    
    it 'should not perform a place search if passed the search term starts with "Constituency of "' do
      Constituency.should_receive(:find_by_name).with('London')
      Place.should_not_receive(:find_all_by_ascii_name_or_alternate_names)
      
      get :index, :q => 'Constituency of London'
    end
    
    it 'should not perform a constituency search if passed the parameter t = p' do
      Constituency.should_not_receive(:find_by_name)
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).exactly(2).times.with('London').and_return([])
      
      get :index, :q => 'London', :t => 'p'
    end
    
    it 'should not perform a place search for "united kingdom"' do
      Constituency.should_receive(:find_by_name)
      Place.should_not_receive(:find_all_by_ascii_name_or_alternate_names)
      
      get :index, :q => 'United Kingdom', :t => 'p'
      get :index, :q => 'United Kingdom'
    end

    it 'should look for a match on place and county when passed a search term formatted as "Town, County"' do
      Constituency.should_receive(:find_by_name)
      place1 = mock_model(Place, :id => 1, :county_name => 'Cheshire')
      place2 = mock_model(Place, 
                            :id => 2, 
                            :county_name => 'Greater London', 
                            :display_name => 'Stoke (Greater London)',
                            :lat => 51.5084, 
                            :lng => -0.125533, 
                            :zoom_level => 7)
      place2.stub!(:placetag)
      place2.stub!(:find_nearby_items).and_return([@item1, @item2, @item3, @item4])
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("Stoke, Greater London").and_return([])
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("Stoke").and_return([place1, place2])
      
      get :index, :q => 'Stoke, Greater London'
    end
  end
end
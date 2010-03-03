require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Constituency do
  describe 'in general' do
    before do
      @constituency = Constituency.new(:name => 'Uxbridge')
    end
    
    it 'should not return a county name' do
      @constituency.county_name.should == nil
    end
    
    it 'should set ascii_name to the value of name' do
      @constituency.ascii_name.should == 'Uxbridge'
    end
    
    it 'should put "Constituency of " in front of the name when asked for a display_name' do
      @constituency.display_name.should == 'Constituency of Uxbridge'
    end
  end
  
  describe 'when asked for zoom level' do
    it 'should return 7 where the constituency covers a very large area' do
      constituency = Constituency.new(:area => 2000000001)
      constituency.zoom_level.should == 7
    end
    
    it 'should return 12 for an average sized constituency' do
      constituency = Constituency.new(:area => 80001)
      constituency.zoom_level.should == 12
    end
  end
  
  describe 'when asked for alternative_places' do
    before do
      @constituency = Constituency.new(:name => 'Southampton, Test')
      @place = mock_model(Place)
    end
    
    it 'should return an empty array if there are no places with the same name' do
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with('Southampton, Test').and_return([])
      @constituency.alternative_places.should == []
    end
    
    it 'should return an array of places if there are places with the same name' do
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with('Southampton, Test').and_return([@place])
      @constituency.alternative_places.should == [@place]
    end
  end
end
require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Place do
  
  describe 'in general' do
    it 'should pass the correct condition string to the database when asked to find by alternate name or ascii name' do
      term = "Essex"
      @place = mock_model(Place, :name => 'County of Essex', :alternate_names => 'Essex')
      Place.should_receive(:find).with(:all, :conditions => "ascii_name = 'Essex' or alternate_names='Essex'").and_return([@place])
      
      Place.find_all_by_ascii_name_or_alternate_names(term).should == [@place]
    end
  end
  
  describe 'when asked for a geotag' do
    before do
      @place = Place.new()
      @place.stub!(:id).and_return(2345)
    end
    
    it 'should return a geotag if there is one' do
      tag = mock_model(Tag)
      Tag.should_receive(:find_by_name_and_kind).with(2345, "geotag").and_return tag
      @place.geotag.should == tag
    end
    
    it 'should return nil if no matching geotag' do
      Tag.should_receive(:find_by_name_and_kind).with(2345, "geotag").and_return nil
      @place.geotag.should == nil
    end
  end
  
end
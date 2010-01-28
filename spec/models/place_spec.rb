require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Place do
  
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
    end
  end
  
end
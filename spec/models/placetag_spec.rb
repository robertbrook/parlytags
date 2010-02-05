require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Placetag do
  describe 'when asked for item_count' do
    before do
      @placetag = Placetag.new(:name => "London")
    end
    
    it 'should return 0 if there are no tags' do
      @placetag.should_receive(:tags).and_return nil
      
      @placetag.item_count.should == 0
    end
    
    it 'should return 4 when there are 4 items' do
      tag = mock_model(Tag)
      @placetag.should_receive(:tags).exactly(2).times.and_return([tag])
      tag.should_receive(:items).and_return([mock_model(Item), mock_model(Item), mock_model(Item), mock_model(Item)])
      
      @placetag.item_count.should == 4
    end
  end
end
require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Item do
  describe 'when asked to find by placetag' do
    before do
      @item1 = mock_model(Item)
      @item2 = mock_model(Item)
      @tag1 = mock_model(Placetag)
      @tag2 = mock_model(Placetag)
    end
  
    it 'should return a list of items when given single tag' do
      Placetag.should_receive(:find_by_name).with("some_tag").and_return(@tag1)
      @tag1.should_receive(:items).and_return([@item1, @item2])
    
      Item.find_all_by_placetag("some_tag").should == [@item1, @item2]
    end
  
    it 'should return a list of items when given an array of tags' do
      Placetag.should_receive(:find).with(:all, :conditions => "name in ('some_tag','some_other_tag')").and_return([@tag1, @tag2])
      @tag1.should_receive(:items).and_return([@item2])
      @tag2.should_receive(:items).and_return([@item1, @item2])
    
      Item.find_all_by_placetag(["some_tag", "some_other_tag"]).should == [@item2, @item1]
    end
  end
end
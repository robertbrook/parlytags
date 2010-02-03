require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Item do
  describe 'when asked to find by tag' do
    before do
      @item1 = mock_model(Item)
      @item2 = mock_model(Item)
      @tag1 = mock_model(Tag)
      @tag2 = mock_model(Tag)
      @taggings1 = mock_model(Tagging, :taggable_id => 4)
      @taggings2 = mock_model(Tagging, :taggable_id => 1)
      @taggings = [@taggings1, @taggings2]
      @tag1.stub!(:taggings).and_return(@taggings1)
      @tag2.stub!(:taggings).and_return(@taggings2)
    end
  
    it 'should return a list of items when given single tag' do
      Tag.should_receive(:find_by_name_and_kind).with("some_tag", "tag").and_return(@tag1)
      @taggings1.stub!(:find_all_by_taggable_type).with("Item").and_return(@taggings)
      Item.should_receive(:find).with([4, 1]).and_return([@item1, @item2])
    
      Item.find_all_by_tag("some_tag").should == [@item1, @item2]
    end
  
    it 'should return a list of edms when given an array of tags' do
      Tag.should_receive(:find).with(:all, :conditions => "name in ('some_tag','some_other_tag') AND kind='tag'").and_return([@tag1, @tag2])
      @taggings1.stub!(:find_all_by_taggable_type).with("Item").and_return([@taggings1])
      @taggings2.stub!(:find_all_by_taggable_type).with("Item").and_return([@taggings2])
      Item.should_receive(:find).with([4, 1]).and_return([@item1, @item2])
    
      Item.find_all_by_tag(["some_tag", "some_other_tag"]).should == [@item1, @item2]
    end
  end

  describe 'when handling geotags' do
    before do
      @item = Item.new()
      @place1 = mock_model(Place, :id => 1234, :ascii_name => "London", :alternate_names => 'LON')
      @place2 = mock_model(Place, :id => 2314, :ascii_name => "Westminster", :alternate_names => '')
    end
    
    it 'should create geotags for each tag that corresponds to a place name when asked to generate geotags' do
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("London").and_return([@place1])
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("Westminster").and_return([@place2])
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("foo").and_return([])
      @item.should_receive(:tag_list).and_return(["London", "Westminster", "foo"])
      @item.stub(:save!)
      
      @item.generate_geotags.should == ["1234", "2314"]
    end
    
    it 'should return an array of tagged place names when asked for place_names' do
      @item.should_receive(:geotag_list).and_return(["1234", "2314"])
      Place.should_receive(:find).with(["1234", "2314"]).and_return([@place1, @place2])
      
      @item.place_names.should == ["LON", "London", "Westminster"]
    end
  end
end
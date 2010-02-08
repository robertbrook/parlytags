require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Item do
  describe 'when asked to find by tag' do
    before do
      @item1 = mock_model(Item)
      @item2 = mock_model(Item)
      @tag1 = mock_model(Tag)
      @tag2 = mock_model(Tag)
    end
  
    it 'should return a list of items when given single tag' do
      Tag.should_receive(:find_by_name).with("some_tag").and_return(@tag1)
      @tag1.should_receive(:items).and_return([@item1, @item2])
    
      Item.find_all_by_tag("some_tag").should == [@item1, @item2]
    end
  
    it 'should return a list of items when given an array of tags' do
      Tag.should_receive(:find).with(:all, :conditions => "name in ('some_tag','some_other_tag')").and_return([@tag1, @tag2])
      @tag1.should_receive(:items).and_return([@item2])
      @tag2.should_receive(:items).and_return([@item1, @item2])
    
      Item.find_all_by_tag(["some_tag", "some_other_tag"]).should == [@item2, @item1]
    end
  end

  describe 'when handling placetags' do
    before do
      @item = Item.new()
      @place1 = mock_model(Place, 
          :id => 1234, 
          :ascii_name => "London", 
          :alternate_names => 'LON', 
          :geoname_id => 2324,
          :admin2_code => 'JA',
          :admin1_code => 'ENG',
          :county => nil,
          :country => mock_model(Place, :ascii_name => "England")
          )
      @place2 = mock_model(Place, 
          :id => 2314, 
          :ascii_name => "Westminster", 
          :alternate_names => '',
          :geoname_id => 3453,
          :admin2_code => '00',
          :admin1_code => 'ENG',
          :county => mock_model(Place, :ascii_name => "Greater London"),
          :country => mock_model(Place, :ascii_name => "England")
          )
      @county1 = mock_model(Place, :id => 1, :ascii_name => 'County of Essex')
      @county2 = mock_model(Place, :id => 4, :ascii_name => 'Hertfordshire')
      @tag1 = mock_model(Tag, :name => "London")
      @tag2 = mock_model(Tag, :name => "Westminster")
      @tag1.stub!(:save)
      @tag2.stub!(:save)
      @placetag1 = mock_model(Placetag)
      @placetag2 = mock_model(Placetag)
      @placetag3 = mock_model(Placetag)
    end
    
    it 'should create placetags for each tag that corresponds to a place name when asked to generate placetags' do
      @item.should_receive(:tags).and_return([@tag1, @tag2])
      @tag1.should_receive(:placetags).and_return([@placetag1])
      @tag2.should_receive(:placetags).and_return([@placetag1, @placetag2])
      Placetag.should_receive(:find_by_geoname_id).exactly(2).times.and_return(nil)
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("London").and_return([@place1])
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("Westminster").and_return([@place2])
      @place1.should_receive(:has_placetag=).with(true)
      @place1.stub!(:save)
      @place2.should_receive(:has_placetag=).with(true)
      @place2.stub!(:save)
      
      @item.stub(:save!)
      
      @item.populate_placetags
    end
  end
end
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
  
  describe 'when asked for age of item' do
    it 'should return "Today" when the item\'s created_at value is today\'s date' do
      item = Item.new(:created_at => Time.now.to_date)
      item.age.should == "Today"
    end
    
    it 'should return "Yesterday" when the item\'s created_at value is yesterday\'s date' do
      item = Item.new(:created_at => (Time.now.to_date - 1))
      item.age.should == "Yesterday"
    end
    
    it 'should return "5 days ago" when the item\'s created_at date is 5 days ago' do
      item = Item.new(:created_at => (Time.now.to_date - 5))
      item.age.should == "5 days ago"
    end
  end
  
  describe 'when asked for a list of placenames' do
    it 'should return "" when there are no placetags' do
      item = Item.new()
      item.should_receive(:placetags).and_return([])
      
      item.placenames.should == []
    end
    
    it 'should return a list of placenames' do
      placetag1 = mock_model(Placetag, :name => 'County of Essex')
      placetag2 = mock_model(Placetag, :name => 'City and County of Cardiff')
      item = Item.new(:placetags => [placetag1, placetag2])
      
      item.placenames.should == ["Essex", "City and County of Cardiff"]
    end
    
    it 'should not return duplicate placenames' do
      placetag1 = mock_model(Placetag, :name => 'County of Essex')
      placetag2 = mock_model(Placetag, :name => 'Essex')
      item = Item.new(:placetags => [placetag1, placetag2])
      
      item.placenames.should == ["Essex"]
    end
  end
  
  describe 'when asked for a display_url' do
    it 'should remove "http://" and "https://"' do
      item = Item.new(:url => 'http://www.google.com')
      item.display_url.should_not =~ /http:\/\//
      
      item = Item.new(:url => 'https://www.google.com')
      item.display_url.should_not =~ /https:\/\//
    end
    
    it 'should return the complete url if it is shorter than 70 characters' do
      item = Item.new(:url => 'http://www.google.com')
      
      item.display_url.should == "www.google.com"
    end
    
    it 'should replace the last folder name of the url with "..." when given a long url' do
      item = Item.new(:url => 'http://www.publications.parliament.uk/cm200910/cmhansrd/cm100201/100201w0009.htm')
      item.display_url.should == "www.publications.parliament.uk/cm200910/cmhansrd/.../100201w0009.htm"
    end
    
    it 'should replace the last 2 folder names of the url with "..." when given a longer url' do
      item = Item.new(:url => 'http://www.publications.parliament.uk/pa/cm200910/cmhansrd/cm100201/100201w0009.htm')
      item.display_url.should == "www.publications.parliament.uk/pa/cm200910/.../100201w0009.htm"
    end
  end
end
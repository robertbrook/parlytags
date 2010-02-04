require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Place do
  
  describe 'when asked to find by ascii_name or alternate_names' do
    it 'should correctly escape the search term' do
      term = "Her Majesty's Opposition's"
      Place.should_receive(:find_all_by_ascii_name).with("Her Majesty\\'s Opposition\\'s")
      
      Place.find_all_by_ascii_name_or_alternate_names(term)
    end
    
    it 'should return a single result where there is a direct name match' do
      term = "Big Ben"
      place = mock_model(Place)
      Place.should_receive(:find).with(:all, :conditions => {:name => 'Big Ben'}).and_return([place])
      Place.should_not_receive(:find).with(:all, :conditions => {:ascii_name => 'Big Ben'})
      Place.should_receive(:find).with(:all, :conditions => "alternate_names = 'Big Ben' or alternate_names like 'Big Ben,%' or alternate_names like '%,Big Ben,%' or alternate_names like '%,Big Ben'").and_return([])
      
      Place.find_all_by_ascii_name_or_alternate_names(term).should == [place]
    end
    
    it 'should return a single result where there is a direct ascii_name match' do
      term = "Big Ben"
      place = mock_model(Place)
      Place.should_receive(:find).with(:all, :conditions => {:name => 'Big Ben'}).and_return([])
      Place.should_receive(:find).with(:all, :conditions => {:ascii_name => 'Big Ben'}).and_return([place])
      Place.should_receive(:find).with(:all, :conditions => "alternate_names = 'Big Ben' or alternate_names like 'Big Ben,%' or alternate_names like '%,Big Ben,%' or alternate_names like '%,Big Ben'").and_return []
      
      Place.find_all_by_ascii_name_or_alternate_names(term).should == [place]
    end
    
    it 'should return a single result where there is one match within alternate_names' do
      term = "Essex"
      place = mock_model(Place, :name => 'County of Essex', :alternate_names => 'Essex')
      Place.should_receive(:find).with(:all, :conditions => {:name => 'Essex'}).and_return([])
      Place.should_receive(:find).with(:all, :conditions => {:ascii_name => 'Essex'}).and_return([])
      Place.should_receive(:find).with(:all, :conditions => "alternate_names = 'Essex' or alternate_names like 'Essex,%' or alternate_names like '%,Essex,%' or alternate_names like '%,Essex'").and_return [place]
      
      Place.find_all_by_ascii_name_or_alternate_names(term).should == [place]
    end
     
     it 'should return an array of results - where there are matches within name and alternate_name' do
       term = "Bedford"
       place1 = mock_model(Place)
       place2 = mock_model(Place)
       place3 = mock_model(Place)
       Place.should_receive(:find).with(:all, :conditions => {:name => 'Bedford'}).and_return([])
       Place.should_receive(:find).with(:all, :conditions => {:ascii_name => 'Bedford'}).and_return([place1])
       Place.should_receive(:find).with(:all, :conditions => "alternate_names = 'Bedford' or alternate_names like 'Bedford,%' or alternate_names like '%,Bedford,%' or alternate_names like '%,Bedford'").and_return [place2, place1, place3]

       Place.find_all_by_ascii_name_or_alternate_names(term).should == [place1, place2, place3]
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
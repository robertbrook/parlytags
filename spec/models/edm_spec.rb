require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Edm do

  describe 'when asked to find by tag' do
    before do
      @edm1 = mock_model(Edm)
      @edm2 = mock_model(Edm)
      @tag1 = mock_model(Tag)
      @tag2 = mock_model(Tag)
      @taggings1 = mock_model(Tagging, :taggable_id => 4)
      @taggings2 = mock_model(Tagging, :taggable_id => 1)
      @taggings = [@taggings1, @taggings2]
      @tag1.stub!(:taggings).and_return(@taggings1)
      @tag2.stub!(:taggings).and_return(@taggings2)
    end
    
    it 'should return a list of edms when given single tag' do
      Tag.should_receive(:find_by_name_and_kind).with("some_tag", "tag").and_return(@tag1)
      @taggings1.stub!(:find_all_by_taggable_type).with("Edm").and_return(@taggings)
      Edm.should_receive(:find).with([4, 1]).and_return([@edm1, @edm2])
      
      Edm.find_all_by_tag("some_tag").should == [@edm1, @edm2]
    end
    
    it 'should return a list of edms when given an array of tags' do
      Tag.should_receive(:find).with(:all, :conditions => "name in ('some_tag','some_other_tag') AND kind='tag'").and_return([@tag1, @tag2])
      @taggings1.stub!(:find_all_by_taggable_type).with("Edm").and_return([@taggings1])
      @taggings2.stub!(:find_all_by_taggable_type).with("Edm").and_return([@taggings2])
      Edm.should_receive(:find).with([4, 1]).and_return([@edm1, @edm2])
      
      Edm.find_all_by_tag(["some_tag", "some_other_tag"]).should == [@edm1, @edm2]
    end
  end
  
  describe 'when handling geotags' do
    before do
      @edm = Edm.new()
      @place1 = mock_model(Place, :id => 1234, :ascii_name => "London")
      @place2 = mock_model(Place, :id => 2314, :ascii_name => "Westminster")
    end
    
    it 'should create geotags for each tag that corresponds to a place name when asked to generate geotags' do
      Place.should_receive(:find_all_by_ascii_name).with("London").and_return([@place1])
      Place.should_receive(:find_all_by_ascii_name).with("Westminster").and_return([@place2])
      Place.should_receive(:find_all_by_ascii_name).with("foo").and_return([])
      @edm.should_receive(:tag_list).and_return(["London", "Westminster", "foo"])
      @edm.stub(:save!)
      
      @edm.generate_geotags.should == ["1234", "2314"]
    end
    
    it 'should return an array of tagged place names when asked for place_names' do
      @edm.should_receive(:geotag_list).and_return(["1234", "2314"])
      Place.should_receive(:find).with(["1234", "2314"]).and_return([@place1, @place2])
      
      @edm.place_names.should == ["London", "Westminster"]
    end
  end
  
  describe 'when checking signature totals' do
    before do
      proposer = mock_model(Proposer)
      sig1 = mock_model(Signatory)
      sig2 = mock_model(Signatory)
      seconder = mock_model(Seconder)
      @edm = Edm.new(
        :proposers => [proposer],
        :signatories => [sig1, sig2],
        :seconders => [seconder]
        )
    end
    
    it 'should return 1 when asked for seconders_count' do
      @edm.seconders_count.should == 1
    end
    
    it 'should return 3 when asked for signatories_and_seconders_count' do
      @edm.signatories_and_seconders_count.should == 3
    end
    
    it 'should return true when asked has_proposer?' do
      @edm.has_proposer?.should == true
    end
  end
  
  describe 'when passed is_amendment?' do
    it 'should return true when the amendment number is 234A1' do
      edm = Edm.new(:number => '234A1')
      edm.is_amendment?.should == true
    end
    
    it 'should return false when the amendment number is 234' do
      edm = Edm.new(:number => '234')
      edm.is_amendment?.should == false
    end
  end
end
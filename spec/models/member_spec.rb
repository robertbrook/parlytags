require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Member do
  before do
    @member = Member.new(:name => 'Smith, Dave')
  end
  
  describe "in general" do
    it 'should return a display name of "Dave Smith" given a member name of "Smith, Dave"' do
      @member.display_name.should == "Dave Smith"
    end
  end
end





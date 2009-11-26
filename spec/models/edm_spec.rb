require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Edm do
  
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
require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Member do
  before do
    @member = Member.new(:id => 1, :name => 'Smith, Dave')
    @edm1 = mock_model(Edm, :session => '2000-2001')
    @edm2 = mock_model(Edm, :session => '2000-2001')
    @edm3 = mock_model(Edm, :session => '1998-1999')
    @proposer1 = mock_model(Proposer, :edm => @edm1)
    @proposer2 = mock_model(Proposer, :edm => @edm2)
    @proposer3 = mock_model(Proposer, :edm => @edm3)
    @signatory1 = mock_model(Signatory, :edm => @edm1)
    @signatory2 = mock_model(Signatory, :edm => @edm2)
    @signatory3 = mock_model(Signatory, :edm => @edm3)
    @seconder1 = mock_model(Seconder, :edm => @edm1)
    @seconder2 = mock_model(Seconder, :edm => @edm2)
    @seconder3 = mock_model(Seconder, :edm => @edm3)
  end
  
  it 'should return a display name of "Dave Smith" given a member name of "Smith, Dave"' do
    @member.display_name.should == "Dave Smith"
  end
  
  it 'should return an array of Edms when asked for edms_proposed' do
    @member.should_receive(:proposers).and_return([@proposer1, @proposer2, @proposer3])
    @member.edms_proposed.should == [@edm1, @edm2, @edm3]
  end
  
  it 'should return an array of Edms for a edms_proposed for a specific session' do
    Proposer.stub(:find_all_by_member_id_and_session_id).and_return([@proposer1, @proposer2])
    @member.edms_proposed('2000-2001').should == [@edm1, @edm2]
  end
  
  it 'should return an array of Edms when asked for edms_signed' do
    @member.should_receive(:signatories).and_return([@signatory1, @signatory2, @signatory3])
    @member.edms_signed.should == [@edm1, @edm2, @edm3]
  end
  
  it 'should return an array of Edms for a edms_signed for a specific session' do
    Signatory.stub(:find_all_by_member_id_and_session_id).and_return([@signatory1, @signatory2])
    @member.edms_signed('2000-2001').should == [@edm1, @edm2]
  end
  
  it 'should return an array of Edms when asked for edms_seconded' do
    @member.should_receive(:seconders).and_return([@seconder1, @seconder2, @seconder3])
    @member.edms_seconded.should == [@edm1, @edm2, @edm3]
  end
  
  it 'should return an array of Edms for a edms_seconded for a specific session' do
    Seconder.stub(:find_all_by_member_id_and_session_id).and_return([@seconder1, @seconder2])
    @member.edms_seconded('2000-2001').should == [@edm1, @edm2]
  end
end





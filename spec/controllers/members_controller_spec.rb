require File.dirname(__FILE__) + '/../spec_helper'

describe MembersController do
  
  describe 'when called with index' do    
    it 'should assign a paginated list of Members to the view' do
      member1 = mock_model(Member, :name => 'a')
      member2 = mock_model(Member, :name => 'b')
      
      Member.should_receive(:paginate).with(:page => "4", :order => 'name').and_return([member1, member2])
      
      get :index, :page => 4
      
      assigns[:members].should == [member1, member2]
    end
  end

  describe 'when called with show' do
    before do
      @session = mock_model(Session, :id => 234, :name => '2001-2002')
      @sessions = [@session]
      @member = mock_model(Member)
    end
    
    it 'should assign a Member to the view' do
      Session.should_receive(:find_by_name).and_return(nil)
      Session.should_receive(:all).and_return(@sessions)
      Member.should_receive(:find).with('a').and_return(@member)
      
      get :show, :member => 'a'
      
      assigns[:member].should == @member
      assigns[:sessions].should == @sessions
    end
    
    it 'should assign assign a session id to the view if passed a valid session name' do
      Session.should_receive(:find_by_name).with('2001-2002').and_return(@session)
      Session.should_receive(:all).and_return(@sessions)
      Member.should_receive(:find).with('a').and_return(@member)
      
      get :show, :member => 'a', :session => '2001-2002'
      
      assigns[:session_id].should == @session.id
      assigns[:member].should == @member
      assigns[:sessions].should== @sessions
    end
  end

  describe 'when called with proposed' do
    before do
      @member = mock_model(Member)
      @proposed_edms = [mock_model(Edm)]
      @edms = [mock_model(Edm)]
    end
    
    it 'should assign a single member and an array of edms to the view' do
      Member.should_receive(:find).with('a').and_return(@member)
      @member.should_receive(:edms_proposed).with(nil).and_return(@proposed_edms)
      @proposed_edms.should_receive(:paginate).with(:page => "4", :order => 'created_at DESC').and_return(@edms)
      
      get :proposed, :member => 'a', :page => 4
      
      assigns[:member].should == @member
      assigns[:edms].should == @edms
    end
    
    it 'should retrieve an array of edms for a single session if passed a valid session name' do
      session = mock_model(Session, :id => 234)
      Session.should_receive(:find_by_name).with('2001-2002').and_return(session)
      Member.should_receive(:find).with('a').and_return(@member)
      @member.should_receive(:edms_proposed).with(234).and_return(@proposed_edms)
      @proposed_edms.should_receive(:paginate).with(:page => "4", :order => 'created_at DESC').and_return(@edms)
      
      get :proposed, :member => 'a', :page => 4, :session => '2001-2002'
      
      assigns[:member].should == @member
      assigns[:edms].should == @edms
    end
  end
  
  describe 'when called with seconded' do
    before do
      @member = mock_model(Member)
      @seconded_edms = [mock_model(Edm)]
      @edms = [mock_model(Edm)]
    end
    
    it 'should assign a single member and an array of edms to the view' do
      Member.should_receive(:find).with('a').and_return(@member)
      @member.should_receive(:edms_seconded).with(nil).and_return(@seconded_edms)
      @seconded_edms.should_receive(:paginate).with(:page => "4", :order => 'created_at DESC').and_return(@edms)
      
      get :seconded, :member => 'a', :page => 4
      
      assigns[:member].should == @member
      assigns[:edms].should == @edms
    end
    
    it 'should retrieve an array of edms for a single session if passed a valid session name' do
      session = mock_model(Session, :id => 234)
      Session.should_receive(:find_by_name).with('2001-2002').and_return(session)
      Member.should_receive(:find).with('a').and_return(@member)
      @member.should_receive(:edms_seconded).with(234).and_return(@seconded_edms)
      @seconded_edms.should_receive(:paginate).with(:page => "4", :order => 'created_at DESC').and_return(@edms)
      
      get :seconded, :member => 'a', :page => 4, :session => '2001-2002'
      
      assigns[:member].should == @member
      assigns[:edms].should == @edms
    end
  end

  describe 'when called with signed' do
    before do
      @member = mock_model(Member)
      @signed_edms = [mock_model(Edm)]
      @edms = [mock_model(Edm)]
    end
    
    it 'should assign a single member and an array of edms to the view' do
      Member.should_receive(:find).with('a').and_return(@member)
      @member.should_receive(:edms_signed).with(nil).and_return(@signed_edms)
      @signed_edms.should_receive(:paginate).with(:page => "4", :order => 'created_at DESC').and_return(@edms)
      
      get :signed, :member => 'a', :page => 4
      
      assigns[:member].should == @member
      assigns[:edms].should == @edms
    end
    
    it 'should retrieve an array of edms for a single session if passed a valid session name' do
      session = mock_model(Session, :id => 234)
      Session.should_receive(:find_by_name).with('2001-2002').and_return(session)
      Member.should_receive(:find).with('a').and_return(@member)
      @member.should_receive(:edms_signed).with(234).and_return(@signed_edms)
      @signed_edms.should_receive(:paginate).with(:page => "4", :order => 'created_at DESC').and_return(@edms)
      
      get :signed, :member => 'a', :page => 4, :session => '2001-2002'
      
      assigns[:member].should == @member
      assigns[:edms].should == @edms
    end
  end

end
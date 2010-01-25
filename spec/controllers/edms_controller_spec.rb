require File.dirname(__FILE__) + '/../spec_helper'

describe EdmsController do

  describe 'when called with index' do    
    it 'should get a list of all Sessions' do
      sessions = [mock_model(Session)]
      Session.should_receive(:all).and_return sessions
      Edm.stub!(:paginate)
      
      get :index
      
      assigns[:sessions].should == sessions
    end
    
    it 'should get a paginated list of EDMs' do
      edms = [mock_model(Edm)]
      Session.stub!(:all)
      Edm.should_receive("paginate").with(:page => params[:page], :order => 'created_at DESC').and_return edms
      
      get :index
      
      assigns[:edms].should == edms
    end
  end

  describe 'when called with show' do
    it "should assign an edm to the view if passed a valid session name and edm number" do
      session_name = '2001-2002'
      edm = mock_model(Edm)
      Session.should_receive(:find_by_name).with(session_name).and_return mock_model(Session, :id => 1)
      Edm.should_receive(:find_by_session_id_and_number).with(1,"4").and_return edm
      
      get :show, :session => session_name, :edm => 4
      
      assigns[:edm].should == edm
    end
    
    it "should not assign an edm to the view if passed an invalid session name" do
      session_name = '2011-2022'
      edm = mock_model(Edm)
      Session.should_receive(:find_by_name).with(session_name).and_return nil
      Edm.should_not_receive(:find_by_session_id_and_number)
      
      get :show, :session => session_name, :edm => 4
      
      assigns[:edm].should == nil
    end
    
    it "should not assign an edm to the view if passed an invalid edm number" do
      session_name = '2001-2002'
      edm = mock_model(Edm)
      Session.should_receive(:find_by_name).with(session_name).and_return mock_model(Session, :id => 1)
      Edm.should_receive(:find_by_session_id_and_number).with(1, "invalid").and_return nil
      
      get :show, :session => session_name, :edm => "invalid"
      
      assigns[:edm].should == nil
    end
  end

  describe 'when called with session' do    
    it "should assign an array of sessions and an array of edms to the view" do
      session_name = '2001-2002'
      session = mock_model(Session)
      sessions = [mock_model(Session)]
      edms = [mock_model(Edm)]
      paginated_edms = [mock_model(Edm)]
      
      Session.should_receive(:all).and_return sessions
      Session.should_receive(:find_by_name).with(session_name).and_return session
      session.should_receive(:edms).and_return edms
      edms.should_receive(:paginate).with(:page => "4", :order=>"created_at DESC").and_return paginated_edms
      
      get :session, :session => session_name, :page => 4
      
      assigns[:sessions].should == sessions
      assigns[:edms].should == paginated_edms
    end
  end

end
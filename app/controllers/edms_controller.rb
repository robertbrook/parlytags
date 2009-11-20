class EdmsController < ApplicationController
  
  def index
    @sessions = Session.all
    @edms = Edm.paginate :page => params[:page], :order => 'created_at DESC'
  end
  
  def show
    session_name = params[:session]
    number = params[:edm]
    session = Session.find_by_name(session_name)
    if session
      @edm = Edm.find_by_session_id_and_number(session.id, number)
    end
  end
  
  def session
    @sessions = Session.all
    session_name = params[:session]
    session = Session.find_by_name(session_name)
    @edms = session.edms.paginate :page => params[:page], :order => 'created_at DESC'
  end
end

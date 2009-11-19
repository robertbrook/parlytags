class MembersController < ApplicationController
  
  def index
    @members = Member.paginate :page => params[:page], :order => 'name'
  end
    
  def show
    member_slug = params[:member]
    session = params[:session]
    
    session = Session.find_by_name(session)
    @session_id = nil
    if session
      @session_id = session.id
    end
    @member = Member.find(member_slug)
    @sessions = Session.all
  end
  
  def proposed
    session_id = nil
    
    if params[:session]
      session = Session.find_by_name(params[:session])
      if session
        session_id = session.id
      end
    end
        
    member_slug = params[:member]
    @member = Member.find(member_slug)
    @edms = @member.edms_proposed(session_id).paginate :page => params[:page], :order => 'created_at DESC'
  end
  
  def seconded
    session_id = nil
    
    if params[:session]
      session = Session.find_by_name(params[:session])
      if session
        session_id = session.id
      end
    end
    
    member_slug = params[:member]
    @member = Member.find(member_slug)
    @edms = @member.edms_seconded(session_id).paginate :page => params[:page], :order => 'created_at DESC'
    @session = params[:session]
  end
  
  def signed
    session_id = nil
    
    if params[:session]
      session = Session.find_by_name(params[:session])
      if session
        session_id = session.id
      end
    end
    
    member_slug = params[:member]
    @member = Member.find(member_slug)
    @edms = @member.edms_signed(session_id).paginate :page => params[:page], :order => 'created_at DESC'
    
  end
end
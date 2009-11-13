class MembersController < ApplicationController
    
  def show
    member_slug = params[:member]
    @member = Member.find(member_slug)
  end
  
  def proposed
    member_slug = params[:member]
    @member = Member.find(member_slug)
    @edms = @member.edms_proposed.paginate :page => params[:page], :order => 'created_at DESC'
  end
  
  def seconded
    member_slug = params[:member]
    @member = Member.find(member_slug)
    @edms = @member.edms_seconded.paginate :page => params[:page], :order => 'created_at DESC'
  end
  
  def signed
    member_slug = params[:member]
    @member = Member.find(member_slug)
    @edms = @member.edms_signed.paginate :page => params[:page], :order => 'created_at DESC'
  end
end
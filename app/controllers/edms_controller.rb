class EdmsController < ApplicationController
  
  def index
    @edms = Edm.paginate :page => params[:page], :order => 'created_at DESC'
  end

end

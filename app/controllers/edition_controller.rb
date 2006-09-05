class EditionController < ApplicationController

  def save
    if params['btnSave']
      do_save
    else
      redirect_to :controller => 'root', :action => 'index'
    end
  end
  
  def do_save; end

end
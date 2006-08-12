class EditionController < ApplicationController

  def save
    do_save if params['btnSave']
    redirect_to(:controller => 'root', :action => 'index')
  end
  
  def do_save; end

end
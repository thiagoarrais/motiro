class EditionController < ApplicationController

  def save
    do_save if params['btnSave']
  end
  
  def do_save; end

end
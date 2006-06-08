class RootController < ApplicationController

  before_filter :store_location
  
  def index
    @locale = params[:locale]
  end

end

require 'core/reporter_fetcher'

class RootController < ApplicationController

  before_filter :store_location
  
end

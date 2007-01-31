require_dependency "login_system"
require "translator"
require 'string_extensions'


# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  include LoginSystem
  include ApplicationHelper
  
  before_filter :set_locale, :setup_renderer
  
  def set_locale
    default_locale = 'en-US'
    request_language = request.env['HTTP_ACCEPT_LANGUAGE']
    request_language = request_language.nil? ? nil : request_language[/[^,;]+/]
    
    @locale = params[:locale] || session[:locale] ||
              request_language || default_locale
    session[:locale] = @locale
    begin
      Locale.set @locale
    rescue
      @locale = default_locale
      Locale.set @locale
    end
  end
  
  def setup_renderer
    @renderer = create_renderer
  end
  
private
  
  def create_renderer
    WikiRenderer.new(my_url_generator, current_locale)
  end

  def my_url_generator
    @url_generator ||= WikiUrlGenerator.new(self)
  end
  
end
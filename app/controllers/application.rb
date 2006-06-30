require_dependency "login_system"

# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
    include LoginSystem
    model :user
    
    before_filter :set_locale
    
    def set_locale
      request_language = request.env['HTTP_ACCEPT_LANGUAGE']
      request_language = request_language.nil? ? nil : request_language.split(',').first
      @locale = params[:locale] || request_language
      if @locale then
        Locale.set @locale
      end
    end
    
end
require_dependency "login_system"

# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
    include LoginSystem
    model :user
    
    before_filter :set_locale
    
    def set_locale
      default_locale = 'en-US'
      request_language = request.env['HTTP_ACCEPT_LANGUAGE']
      request_language = request_language.nil? ?
                             nil : request_language.split(/,|;/).first

      @locale = params[:locale] ||
                request_language ||
                session[:locale] ||
                default_locale
      session[:locale] = @locale
      begin
          Locale.set @locale
      rescue
          @locale = default_locale
          Locale.set @locale
      end
      
    end
    
end
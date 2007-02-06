#  Motiro - A project tracking tool
#  Copyright (C) 2006-2007  Thiago Arrais
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

require_dependency "login_system"
require "translator"
require 'string_extensions'

# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  include LoginSystem
  include ApplicationHelper
  
  before_filter :set_locale, :setup_renderer, :check_desired_login_available
  
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
  
  def check_desired_login_available
    if current_user.nil?
      desired_login = params[:desired_login] || flash[:desired_login]
      @login_not_available = ! User.find_by_login(desired_login).nil?
    end
    true
  end
  
private
  
  def create_renderer
    WikiRenderer.new(my_url_generator, current_locale)
  end

  def my_url_generator
    @url_generator ||= WikiUrlGenerator.new(self)
  end
  
end
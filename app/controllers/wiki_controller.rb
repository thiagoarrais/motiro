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

class WikiController < EditionController

  layout :choose_layout

  before_filter :login_required, :except => [:show, :last]
  before_filter :fetch_page
  before_filter :check_edit_access, :only => [:edit, :save]
  
  def choose_layout
    return 'wiki_show' unless params[:context] == 'partial' || params[:action] == 'properties'
    return nil
  end
    
  def protect?(action)
    return false if 'show' == action
    return true    
  end
    
  def initialize(page_provider=Page)
    @real_page_provider = page_provider
    @default_page_provider = DefaultPageProvider.new
  end
  
  def fetch_page
    @page = find_page(params[:page_name])
  end
  
  def check_edit_access
    unless current_user.can_edit?(@page)
      flash[:not_authorized] = true
      redirect_to :action => 'show', :page_name => @page.name
      return false
    end
    
    return true
  end
    
  def edit
    render(:layout => 'application')
  end
  
  def new
    @page.kind = params[:kind]
    render(:action => 'edit', :layout => 'application')
  end
  
  def properties
    sleep 2
  end
  
  def do_save
    params[:page].delete(:original_author_id)
    params[:page].delete(:editors) unless current_user.can_change_editors?(@page)

    @page.original_author ||= current_user
    @page.last_editor = current_user
    @page.modified_at = Time.now
    @page.attributes = params[:page]
    @page.save

    if 'MainPage' == @page.name
      redirect_to :controller => 'root', :action => 'index'
    else
      redirect_to :action => 'show', :page_name => @page.name
    end
  end
  
private

  def find_page(name)
    @real_page_provider.find_by_name(name) ||
    @default_page_provider.find_by_name(name)
  end
    
end

#  Motiro - A project tracking tool
#  Copyright (C) 2006  Thiago Arrais
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

  before_filter :login_required
  before_filter :check_edit_access, :only => [:edit, :save]
  
  def choose_layout
    return 'wiki_show' unless params[:context] == 'partial'
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
  
  def check_edit_access
    @page = find_page(params[:page_name])
    unless current_user.can_edit?(@page)
      flash[:not_authorized] = true
      redirect_to :action => 'show', :page_name => @page.name
      return false
    end
    
    return true
  end
    
  def edit
    render(:layout => 'wiki_edit')
  end
    
  def do_save
    params[:page].delete(:original_author_id)
    params[:page].delete(:editors) unless current_user.can_change_editors?(@page)

    @page.original_author ||= current_user
    @page.attributes = params[:page]
    @page.save

    if 'MainPage' == @page.name
      redirect_to :controller => 'root', :action => 'index'
    else
      redirect_to :action => 'show', :page_name => @page.name
    end
  end
  
  def show
    @page = find_page(params[:page_name])
    @rendered_page = @page.render_html(current_locale)
  end
    
private

  def find_page(name)
    @real_page_provider.find_by_name(name) ||
    @default_page_provider.find_by_name(name)
  end
    
end

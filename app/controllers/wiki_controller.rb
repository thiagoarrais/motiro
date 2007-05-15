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

class WikiController < ApplicationController

  layout :choose_layout

  before_filter :login_required, :except => [:show, :last, :history]
  before_filter :fetch_page, :fetch_revision
  before_filter :check_edit_access, :only => [:edit, :save]
  
  cache_sweeper :page_sweeper, :only =>  [:edit, :save]

  def choose_layout
    return if params[:context] == 'partial' || params[:action] == 'properties_edit'
    return 'application'
  end
    
  def protect?(action)
    return false if 'show' == action
    return true    
  end
    
  def initialize(page_provider=Page, renderer=nil)
    @renderer = renderer || create_renderer
    @real_page_provider = page_provider
    @default_page_provider = DefaultPageProvider.new
  end
  
  def fetch_page
    @page = find_page(params[:page_name])
    unless 'common' == @page.kind 
      @crumbs <<{ @page.kind.pluralize.capitalize.t  =>
                  {:controller => 'report', :action => 'older',
                   :reporter => @page.kind.pluralize}}
    end
    @crumbs <<{ @page.title => {:controller => 'wiki', :action => 'show',
                                :page_name => @page.name} }
  end
  
  def fetch_revision
    rev = params[:revision]
    unless rev.nil?
      @page = @page.revisions[rev.to_i - 1]
      @page_revision_id = @page.id
      @crumbs << { 'Revision %s' / rev =>
                   { :controller => 'wiki', :action => 'show',
                     :page_name => @page.name, :revision => rev} }
    end
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
  
  def save
    if params['btnSave']
      really_save
    else
      redirect_to :controller => 'root', :action => 'index'
    end
  end
  
  def access_denied
    redirect_to :controller => 'wiki', :action => 'show',
                :page_name => params[:page_name] 
  end
  
private

  def really_save
    @page.revise(current_user, Time.now, params[:page])

    if 'MainPage' == @page.name
      redirect_to :controller => 'root', :action => 'index'
    else
      redirect_to :action => 'show', :page_name => @page.name
    end
  end

  def find_page(name)
    @real_page_provider.find_by_name(name) ||
    @default_page_provider.find_by_name(name)
  end
    
end

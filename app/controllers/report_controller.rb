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

require 'models/headline'

require_dependency 'core/chief_editor'

class ReportController < ApplicationController
  
  layout :determine_layout
  
  before_filter do |me|
    me.instance_eval do
      @name = params[:reporter]
    end
  end

  before_filter(:only => [:rss, :list]) do |me|
    me.instance_eval do
      @headlines = @chief_editor.latest_news_from @name
    end
  end
  
  def initialize(chief_editor=ChiefEditor.new)
    @chief_editor = chief_editor
  end
  
  def determine_layout
    return 'application' if params[:id] and params[:context] != 'partial' or
                            params[:action] == 'older'
    return nil
  end
  
  def list
    @title = @chief_editor.title_for @name
    @toolbar = @chief_editor.toolbar_for @name
  end
  
  def older
    @headlines = @chief_editor.news_from @name
    @title = @chief_editor.title_for @name
  end
  
  def show
    id = params[:id]
    context = params[:context] || 'full'
    
    begin
      @revision_id = id
      @headline = @chief_editor.headline_with(@name, id)
      @partial = context == 'partial'
      
      render(:action => "#{@name}_detail")
    rescue
      logger.error("Tried to access invalid headline #{id} from #{@name}")
      flash[:notice] = 'The article %s from the %s reporter could not be found' / id / @name.capitalize
      redirect_to(:controller => 'root', :action => 'index')
    end            
  end
  
end

#  Motiro - A project tracking tool
#  Copyright (C) 2006-2008  Thiago Arrais
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

require 'core/reporter'
require 'core/settings'

class WikiReporter < MotiroReporter

  caching :off

  def default_opts
    { :settings => SettingsProvider.new, :page_provider => Page }
  end
  
  def initialize(opts={})
    opts = default_opts.merge(opts)
    @settings, @page_provider = opts[:settings], opts[:page_provider]
  end
  
  def self.inherited(klass)
    klass.add(button[:older])
    klass.add(button_for_creating(klass.reporter_name.chop))
  end

  def latest_headlines(rid='')
    @page_provider.find(:all, find_opts.merge(
                                :limit => @settings.package_size)).
      map {|p| p.to_headline}
  end
  
  def headlines
    @page_provider.find(:all, find_opts).map {|p| p.to_headline}
  end
  
  def params_for(page_name)
    { :controller => 'wiki', :action => 'show', :page_name => page_name }
  end
  
  def column; 'modified_at'; end
  
private

  def self.button_for_creating(kind)
    "if current_user.nil?; " +
    "  content_tag('span', 'Add'.t, :class => 'disabled'); " +
    "else; " +
    "  link_to( 'Add'.t, :controller => 'wiki', " + 
                        ":action => 'new', :kind => '#{kind}'); " +
    "end;"
  end

  def find_opts
    { :conditions => "kind = '#{name.singularize}'", :order => "#{column} DESC" }
  end
  
end

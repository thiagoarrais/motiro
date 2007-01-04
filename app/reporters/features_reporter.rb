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

require 'core/reporter'
require 'core/settings'

DEFAULT_AUTHOR = 'someone'
DEFAULT_TIME = Time.local(2007, 1, 3, 15, 10)

class FeaturesReporter < MotiroReporter
  title 'Recently changed suggestions'
  add button[:new_feature]
  caching :off

  def initialize(settings=SettingsProvider.new)
    @settings = settings
  end
  
  def latest_headlines
    to_headlines Page.find(:all, :conditions => "kind = 'feature'",
                           :order => 'modified_at DESC',
                           :limit => @settings.package_size)
  end
  
  def headlines
    to_headlines Page.find(:all, :conditions => "kind = 'feature'",
                           :order => 'modified_at DESC')
  end
  
  def params_for(page_name)
    {:controller => 'wiki', :action => 'show', :page_name => page_name}
  end
  
private

  def to_headlines(pages)
    pages.map do |page|
      Headline.new(:rid => page.name,
                   :author => page.last_editor ? page.last_editor.login : DEFAULT_AUTHOR,
                   :happened_at => page.modified_at || DEFAULT_TIME,
                   :description => page.title)
    end
  end

end

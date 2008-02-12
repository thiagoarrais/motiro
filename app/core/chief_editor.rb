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

require_dependency 'reporters/svn_settings'
require_dependency 'models/headline'

require_dependency 'core/cache_reporter_fetcher'
require_dependency 'core/reporter_fetcher'
require_dependency 'core/settings'

# The ChiefEditor is the guy that makes all the reporters work
class ChiefEditor
  
  def initialize(conf=SettingsProvider.new, fetcher=ReporterFetcher.new)
    @reporters = Hash.new
    
    fetcher = CacheReporterFetcher.new(fetcher, conf) unless
      conf.update_interval == 0
    fetcher.active_reporters.each do |reporter|
      self.employ(reporter)
    end
  end
  
  def latest_news_from(reporter_name)
    @reporters[reporter_name].latest_headlines
  end
  
  def news_from(reporter_name)
    @reporters[reporter_name].headlines
  end
  
  def reporter_with(reporter_name)
    @reporters[reporter_name]
  end
  
  def headline_with(reporter_name, rid)
    @reporters[reporter_name].headline(rid)
  end
  
  def title_for(reporter_name)
    reporter = @reporters[reporter_name]
    return reporter.channel_title
  end
  
  def buttons_for(reporter_name)
    reporter = @reporters[reporter_name]
    return reporter.buttons
  end
  
  # Adds the given reporter to the set of reporters employed by the editor
  def employ(reporter)
    @reporters.update(reporter.name => reporter)
  end
  
end

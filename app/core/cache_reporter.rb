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

require 'core/settings'
require 'core/reporter'

# A cache reporter is a reporter that just repeats news discovered by real
# reporters
#
# Every cache reporter has a real reporter that it tries to mimic. This type
# of reporter will go to the news database and retrieve all news that its real
# correspondent reported.
class CacheReporter < MotiroReporter
  
  def initialize(reporter, settings=SettingsProvider.new,
                 headlines_source=Headline)
    @headlines_source = headlines_source
    @settings = settings
    @source_reporter = reporter
  end
  
  def latest_headlines
    @headlines_source.latest(@settings.package_size, name)
  end
  
  def headlines
    @headlines_source.find(:all, :conditions => ['reported_by = ?', name],
                                 :order => 'happened_at DESC')
  end
  
  def headline(rid)
    @headlines_source.find_with_reporter_and_rid(name, rid)
  end
  
  def name; @source_reporter.name; end
  def channel_title; @source_reporter.channel_title; end
  def params_for(rid); @source_reporter.params_for(rid); end
  
end
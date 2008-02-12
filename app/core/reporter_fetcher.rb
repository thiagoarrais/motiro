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

require_dependency 'core/settings'
require_dependency 'ports/reporter_loader'

require 'reporters/events_reporter'
require 'reporters/features_reporter'

class ReporterFetcher

  def initialize(settings=SettingsProvider.new, loader=ReporterLoader.new)
    @settings, @loader = settings, loader
  end
  
  def active_reporters
    reporters = @settings.active_reporter_ids.map do |rid|
      @loader.create_reporter(rid)
    end
    
    reporters << FeaturesReporter.new
    reporters << EventsReporter.new
  end

end
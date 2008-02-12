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

require 'core/reporter_fetcher'
require 'headline'

class ReporterDriver

  def initialize(fetcher=ReporterFetcher.new, headline_cache=Headline)
    @fetcher, @headline_cache = fetcher, headline_cache
  end

  def tick
    @fetcher.active_reporters.each do |reporter|
      rid = @headline_cache.latest_filled_headline_rid_for(reporter.name)
      reporter.latest_headlines(rid).each do |hl|
        hl.cache
      end
    end
  end

end
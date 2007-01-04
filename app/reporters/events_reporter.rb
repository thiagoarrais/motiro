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

require 'core/cache_reporter'
require 'core/reporter'

require 'stub_hash'

class EventsReporter < MotiroReporter
  title 'Upcoming events'
  add button[:add_events]

  caching :off
  
  def initialize
    @reporter = CacheReporter.new(self)
  end
  
  def store_event(params)
    headline = Headline.new(params)
    
    previous_hl = 0
    until previous_hl.nil?
      id = (rand * 100000).to_i
      previous_hl = Headline.find(:first,
        :conditions => ["reported_by = 'events' and rid = ?", "e#{id}"])
    end
    
    headline.rid = "e#{id}"
    headline.reported_by = name
    
    headline.save
    
    return headline
  end
  
  def method_missing(name, *args)
    @reporter.send(name, *args)
  end
  
end
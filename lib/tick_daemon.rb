#  tick_daemon.rb based on the Rails' Daemon Generator by Kyle Maxwell
#
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

require File.dirname(__FILE__) + "/../config/environment"

require 'core/reporter_driver'
require 'core/settings'

$running = true;
Signal.trap("TERM") do 
  $running = false
end

interval = SettingsProvider.new.update_interval
driver = ReporterDriver.new

if interval > 0
  while($running) do
    driver.tick
    sleep(60 * interval)
  end
end
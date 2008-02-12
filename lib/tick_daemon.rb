#  tick_daemon.rb based on the Rails' Daemon Generator by Kyle Maxwell
#
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

require File.dirname(__FILE__) + "/../config/environment"

require 'core/reporter_driver'
require 'core/settings'

interval = SettingsProvider.new.update_interval
driver = ReporterDriver.new
log = File.new(
  File.expand_path(File.dirname(__FILE__) + '/../log/ticker.log'),
  File::CREAT|File::APPEND|File::WRONLY)

if interval > 0
  log.puts %{Reporters looking for new headlines every #{interval} minutes}
  loop do
    log.puts %{Sendind reporters out at #{Time.now.to_s}}
    log.flush
    begin; driver.tick; rescue; end
    sleep(60 * interval)
  end
end

log.close

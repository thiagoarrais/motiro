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

require 'rubygems'
require 'platform'

class PlatformThread

  def initialize(platform=self, process=self)
    @platform, @process = platform, process
    
    if :win32 == platform.OS
      @pid = process.fork_win32_process { yield }
    else
      @thread = process.new_thread { yield }
    end
  end
  
  def kill
    if :win32 == @platform.OS
      @process.kill_win32_process(9, @pid)
    else
      @thread.kill
    end
  end
  
  def OS
    Platform::OS
  end

  def fork_win32_process
    require 'win32/process'
    Process.fork do
      yield
    end
  end
  
  def kill_win32_process(signal, pid)
    require 'win32/process'
    Process.kill(signal, pid)
  end
  
  def new_thread
    Thread.new { yield }
  end

end


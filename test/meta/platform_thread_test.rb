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

require File.dirname(__FILE__) + '/../test_helper'

require 'platform_thread'

class PlatformThreadTest < Test::Unit::TestCase
  
  def test_uses_win32_process_under_win32
    FlexMock.use 'platform', 'process' do |platform, process|
      platform.should_receive(:OS).and_return(:win32).zero_or_more_times
      process.should_receive(:fork_win32_process).and_return(333).once
      process.should_receive(:kill_win32_process).with(9, 333).once

      thr = PlatformThread.new(platform, process) do; end
      thr.kill
    end
  end
  
  def test_uses_threads_under_unix
    FlexMock.use 'platform', 'process', 'thread' do |platform, process, thread|
      platform.should_receive(:OS).and_return(:unix).zero_or_more_times
      process.should_receive(:new_thread).and_return(thread).once
      thread.should_receive(:kill).once

      thr = PlatformThread.new(platform, process) do; end
      thr.kill
    end
  end
  
end
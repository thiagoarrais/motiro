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

require 'ports/chdir_runner'

class ChdirRunnerTest < Test::Unit::TestCase

  def setup
    @prevdir = Dir.pwd
    assert_not_equal('/tmp', @prevdir)
  end
  
  def test_changes_dir_before_command_and_rollsback_after
    FlexMock.use do |runner|
      runner.should_receive(:run).with('my_command', '', {}).once.
        returns { assert_equal('/tmp', Dir.pwd) }
        
      prevdir = Dir.pwd
      
      cdrunner = ChdirRunner.new('/tmp', runner)
      cdrunner.run('my_command')
      
      assert_equal(prevdir, Dir.pwd)
    end
  end
  
  def test_rollsback_dir_even_on_error
    FlexMock.use do |runner|
      runner.should_receive(:run).with('my_command', '', {}).once.
        returns { raise 'fatal error' }
        
      prevdir = Dir.pwd
      
      begin
        cdrunner = ChdirRunner.new('/tmp', runner)
        cdrunner.run('my_command')
      rescue
        #just ignore the expected error
      end
      
      assert_equal(prevdir, Dir.pwd)
    end
  end
  
  def test_returns_inner_runner_result
    FlexMock.use do |runner|
      runner.should_receive(:run).with('my_command', '', {}).once.
        returns('expectedd output')
        
      cdrunner = ChdirRunner.new('/tmp', runner)
      assert_equal 'expectedd output', cdrunner.run('my_command')
    end
  end
  
  def teardown
    Dir.chdir @prevdir
  end

end

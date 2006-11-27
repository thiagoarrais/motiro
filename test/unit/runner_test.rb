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

require 'ports/runner'

class RunnerTest < Test::Unit::TestCase

  def test_feeds_inner_process_given_input
    FlexMock.use('creator') do |creator|
      command = 'svn diff https://svn.sourceforge.net/svnroot/motiro/ -r363:364'
      output = "diff\n"
      pin, pout, perr = StringIO.new, StringIO.new(output),  StringIO.new
      creator.should_receive(:popen3).
        with(command).
        and_return([pin, pout, perr]).
        once

      runner = Runner.new(creator)
      assert_equal output, runner.run(command, "t\n")
      assert_equal "t\n", pin.string
    end
  end
  
  def test_augments_and_cleans_environment
    FlexMock.use('creator') do |creator|
      command = 'svn log -v https://svn.sourceforge.net/svnroot/motiro/ -r363'
      creator.should_receive(:popen).with(command, 'r+').once.
        returns do
          assert_equal 'test_value', ENV['TEST_VAR']
          StringIO.new
        end

      Runner.new(creator).run(command, '', 'TEST_VAR' => 'test_value')
      
      assert_nil ENV['TEST_VAR']
    end
  end
  
  def test_cleans_overlapping_environment
    FlexMock.use('creator') do |creator|
      command = 'svn diff https://svn.sourceforge.net/svnroot/motiro/ -r363:364'
      output = "diff\n"
      pin, pout, perr = StringIO.new, StringIO.new(output),  StringIO.new
      creator.should_receive(:popen3).
        with(command).
        and_return([pin, pout, perr]).
        once

      Runner.new(creator).run(command, '', 'FIRST_TEST_VAR' => 'first_value',
                                           'SECOND_TEST_VAR' => 'second_value')

      assert_equal 'original_value', ENV['FIRST_TEST_VAR']
      assert_nil ENV['SECOND_TEST_VAR']
    end
  end
  
  def test_recovers_from_broken_pipe_io_error
    pin = Object.new
    def pin.method_missing(name, *args)
      raise Errno::EPIPE
    end
    
    FlexMock.use('creator') do |creator|
      command = 'svn diff https://svn.sourceforge.net/svnroot/motiro/ -r363:364'
      output = "diff command output\n"
      pout, perr = StringIO.new(output),  StringIO.new
      creator.should_receive(:popen3).
        with(command).
        and_return([pin, pout, perr]).
        once

      assert_equal output, Runner.new(creator).run(command)
    end
  end
  
  def setup
    ENV['FIRST_TEST_VAR'] = 'original_value'
  end
  
  def teardown
    ENV.delete 'FIRST_TEST_VAR'
  end
  
end

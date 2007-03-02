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

require File.dirname(__FILE__) + '/../test_helper'

require 'test/unit'

require 'reporters/svn_connection'

require 'stubs/svn_settings'

class SubversionConnectionTest < Test::Unit::TestCase
  
  def test_reads_repo_url
    FlexMock.use do |runner|
      settings = StubConnectionSettingsProvider.new(
                   :repo => 'svn://svn.berlios.de/motiro')
      
      runner.should_receive(:run).once.
        with('svn log svn://svn.berlios.de/motiro -v -rHEAD:1 --limit=5',
             "t\n", 'LC_MESSAGES' => 'C')
      
      connection = SubversionConnection.new(settings, runner)
      
      connection.log
    end
  end

  def test_issues_commands_with_credentials
    FlexMock.use do |runner|
      settings = StubConnectionSettingsProvider.new(
                   :repo => 'http://rapidsvn.tigris.org/svn/rapidsvn/trunk',
                   :repo_user => 'guest',
                   :repo_password => 'with spaces')
      
      runner.should_receive(:run).once.
        with("svn --username='guest' --password='with spaces' log http://rapidsvn.tigris.org/svn/rapidsvn/trunk -v -rHEAD:1 --limit=5",
             "t\n", 'LC_MESSAGES' => 'C')
      runner.should_receive(:run).once.
        with("svn --username='guest' --password='with spaces' info -r18 --xml http://rapidsvn.tigris.org/svn/rapidsvn/trunk/trunk/file_a.txt",
             "t\n", 'LC_MESSAGES' => 'C')
      runner.should_receive(:run).once.
        with("svn --username='guest' --password='with spaces' diff http://rapidsvn.tigris.org/svn/rapidsvn/trunk -r17:18",
             "t\n", 'LC_MESSAGES' => 'C')
      
      connection = SubversionConnection.new(settings, runner)
      
      connection.log
      connection.info('/trunk/file_a.txt', 18)
      connection.diff(18)
    end
  end

  def test_limit_query_size
    FlexMock.use do |runner|
      settings = StubConnectionSettingsProvider.new :package_size => 3
      
      runner.should_receive(:run).once.
        with('svn log http://svn.fake.domain.org/fake_repo -v -rHEAD:1 --limit=3',
             "t\n", 'LC_MESSAGES' => 'C')
      
      connection = SubversionConnection.new(settings, runner)
      
      connection.log
    end
  end
  
  def test_limit_to_one_revision
    FlexMock.use do |runner|
      settings = StubConnectionSettingsProvider.new
      
      runner.should_receive(:run).twice.
        with('svn log http://svn.fake.domain.org/fake_repo -v -r7',
             "t\n", 'LC_MESSAGES' => 'C')
      
      connection = SubversionConnection.new(settings, runner)
      
      connection.log(:only => 7)
      connection.log(:only => '7')
    end
  end
  
  def test_diff
    FlexMock.use do |runner|
      settings = StubConnectionSettingsProvider.new
      
      runner.should_receive(:run).once.
        with('svn diff http://svn.fake.domain.org/fake_repo -r14:15',
             "t\n", 'LC_MESSAGES' => 'C')
      
      connection = SubversionConnection.new(settings, runner)
      
      connection.diff(15)
    end
  end
  
  def test_cache_results_to_avoid_network_usage
    FlexMock.use do |runner|
      settings = StubConnectionSettingsProvider.new
      expected_diff_output = 'diff output'
      
      runner.should_receive(:run).with_any_args.
        once.
        returns(expected_diff_output)
      
      connection = SubversionConnection.new(settings, runner)
      assert_equal expected_diff_output, connection.diff(18)
      assert_equal expected_diff_output, connection.diff(18)
    end
  end
  
  def test_info
    FlexMock.use do |runner|
      settings = StubConnectionSettingsProvider.new
      
      runner.should_receive(:run).once.
        with('svn info -r18 --xml http://svn.fake.domain.org/fake_repo/trunk/file_a.txt',
             "t\n", 'LC_MESSAGES' => 'C')
      
      connection = SubversionConnection.new(settings, runner)
      
      connection.info('/trunk/file_a.txt', 18)
    end
  end
  
  def test_uses_english_locale_and_temporarily_accepts_ssl_certificate
    FlexMock.use do |runner|
      runner.should_receive(:run).once.
        with('svn log http://svn.fake.domain.org/fake_repo -v -rHEAD:1 --limit=5',
             "t\n", 'LC_MESSAGES' => 'C')
      
      connection = SubversionConnection.new(StubConnectionSettingsProvider.new,
                     runner)
      
      connection.log
    end
  end
  
  def test_unlimited_logging
    FlexMock.use do |runner|
      settings = StubConnectionSettingsProvider.new
      
      runner.should_receive(:run).once.
        with('svn log http://svn.fake.domain.org/fake_repo -v',
             "t\n", 'LC_MESSAGES' => 'C')
      
      connection = SubversionConnection.new(settings, runner)
      
      connection.log(:all)
    end
  end
  
  def test_log_history_from_some_revision
    FlexMock.use do |runner|
      settings = StubConnectionSettingsProvider.new

      runner.should_receive(:run).once.
        with('svn log http://svn.fake.domain.org/fake_repo -v -rHEAD:13 --limit=5',
             "t\n", 'LC_MESSAGES' => 'C')

      connection = SubversionConnection.new(settings, runner)

      connection.log(:history_from => 'r12')
    end
  end
  
  # TODO what happens if we ask for an inexistent revision
  
end
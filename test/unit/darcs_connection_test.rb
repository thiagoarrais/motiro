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

require 'fileutils'

require 'reporters/darcs_connection'

class DarcsConnectionTest  < Test::Unit::TestCase

  TMP = TEMP_DIR + '/tmprepo'
  
  def setup
    FileUtils.mkdir_p(TMP)
  end

  def test_reads_settings
    FlexMock.use('1', '2') do |runner, repo_dir|
      settings = StubConnectionSettingsProvider.new(
                 :repo => 'http://motiro.sf.net/darcsrepo/trunk',
                 :package_size => 7)
      repo_dir.should_receive(:path).once.
        returns(TMP)
      runner.should_receive(:run).once.
        with('darcs changes --xml --last=7', '', {}).
        returns('')
        
      connection = DarcsConnection.new(settings, runner, repo_dir)
      
      connection.changes
    end
  end
  
  def test_provides_full_change_log
    FlexMock.use('1', '2') do |runner, repo_dir|
      settings = StubConnectionSettingsProvider.new
      repo_dir.should_receive(:path).once.returns(TMP)
      runner.should_receive(:run).once.
        with("darcs changes --xml", '', {}).returns('')
        
      DarcsConnection.new(settings, runner, repo_dir).changes(:all)
    end
  end

  def test_changes_with_hashcode_parameter_asks_for_only_one_patch
    FlexMock.use('1', '2') do |runner, repo_dir|
      hashcode = '20060717200939-49d33-c04fbb63892ae64cd96d1ad8f1ad2dd0a6e8e7da.gz'
      settings = StubConnectionSettingsProvider.new(
                 :repo => 'http://motiro.sf.net/darcsrepo/trunk')
      repo_dir.should_receive(:path).once.
        returns(TMP)
      runner.should_receive(:run).once.
        with('darcs changes --xml' +
                          " --from-match=\"hash #{hashcode}\"" +
                          " --to-match=\"hash #{hashcode}\"", '', {}).
        returns('')
        
      connection = DarcsConnection.new(settings, runner, repo_dir)
      
      connection.changes(hashcode)
    end
  end
  
  def test_pulling
    FlexMock.use('1', '2') do |runner, repo_dir|
      settings = StubConnectionSettingsProvider.new(
                 :repo => 'http://motiro.sf.net/darcsrepo/trunk')
      repo_dir.should_receive(:path).once.returns(TMP)
      runner.should_receive(:run).once.
        with('darcs pull -a http://motiro.sf.net/darcsrepo/trunk', '', {}).
        returns('')
        
      DarcsConnection.new(settings, runner, repo_dir).pull
    end
  end
  
  def test_diffing
    FlexMock.use('1', '2') do |runner, repo_dir|
      hashcode = '20060717200939-49d33-c04fbb63892ae64cd96d1ad8f1ad2dd0a6e8e7da.gz'
      settings = StubConnectionSettingsProvider.new
      repo_dir.should_receive(:path).once.returns(TMP)
      runner.should_receive(:run).once.
        with("darcs diff -u --match \"hash #{hashcode}\"", '', {}).
        returns('')
        
      DarcsConnection.new(settings, runner, repo_dir).diff(hashcode)
    end
  end
  
  def teardown
    FileUtils.rm_rf(TMP)
  end

end

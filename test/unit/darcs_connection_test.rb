require File.dirname(__FILE__) + '/../test_helper'

require 'reporters/darcs_connection'

class DarcsConnectionTest  < Test::Unit::TestCase

  def test_reads_settings
    FlexMock.use('1', '2') do |runner, repo_dir|
      settings = StubConnectionSettingsProvider.new(
                 :repo => 'http://motiro.sf.net/darcsrepo/trunk',
                 :package_size => 7)
      repo_dir.should_receive(:path).once.
        returns('/tmp/tmprepo')
      runner.should_receive(:run).once.
        with('darcs changes --xml --last=7 ' +
                           '--repo=http://motiro.sf.net/darcsrepo/trunk ' +
                           '--repodir="/tmp/tmprepo"').
        returns('')
        
      connection = DarcsConnection.new(settings, runner, repo_dir)
      
      connection.changes
    end
  end
  
  def test_changes_with_hashcode_parameter_asks_for_only_one_patch
    FlexMock.use('1', '2') do |runner, repo_dir|
      hashcode = '20060717200939-49d33-c04fbb63892ae64cd96d1ad8f1ad2dd0a6e8e7da.gz'
      settings = StubConnectionSettingsProvider.new(
                 :repo => 'http://motiro.sf.net/darcsrepo/trunk')
      repo_dir.should_receive(:path).once.
        returns('/tmp/tmprepo')
      runner.should_receive(:run).once.
        with('darcs changes --xml' +
                          " --from-match=\"hash #{hashcode}\"" +
                          " --to-match=\"hash #{hashcode}\"" +
                          ' --repo=http://motiro.sf.net/darcsrepo/trunk' +
                          ' --repodir="/tmp/tmprepo"').
        returns('')
        
      connection = DarcsConnection.new(settings, runner, repo_dir)
      
      connection.changes(hashcode)
    end
  end
  
end

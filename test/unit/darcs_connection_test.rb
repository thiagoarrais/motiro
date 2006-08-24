require File.dirname(__FILE__) + '/../test_helper'

require 'reporters/darcs_connection'

class DarcsConnectionTest  < Test::Unit::TestCase

  def test_reads_repo_url
    FlexMock.use do |runner|
      settings = StubConnectionSettingsProvider.new(
                 :repo => 'http://motiro.sf.net/darcsrepo/trunk')
      runner.should_receive(:run).once.
        with('darcs changes --xml --repo=http://motiro.sf.net/darcsrepo/trunk').
        returns('')
        
      connection = DarcsConnection.new(settings, runner)
      
      connection.changes
    end
  end
  
  def test_changes_with_hashcode_parameter_asks_for_only_one_patch
    FlexMock.use do |runner|
      hashcode = '20060717200939-49d33-c04fbb63892ae64cd96d1ad8f1ad2dd0a6e8e7da.gz'
      settings = StubConnectionSettingsProvider.new(
                 :repo => 'http://motiro.sf.net/darcsrepo/trunk')
      runner.should_receive(:run).once.
        with('darcs changes --xml' +
                          " --from-match=\"hash #{hashcode}\"" +
                          " --to-match=\"hash #{hashcode}\"" +
                          ' --repo=http://motiro.sf.net/darcsrepo/trunk').
        returns('')
        
      connection = DarcsConnection.new(settings, runner)
      
      connection.changes(hashcode)
    end
  end

end

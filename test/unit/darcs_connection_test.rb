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

end

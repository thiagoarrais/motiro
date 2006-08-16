require File.dirname(__FILE__) + '/../test_helper'

require 'reporters/darcs_reporter'

class DarcsReporterTest  < Test::Unit::TestCase

  P1 = <<END
<changelog>
<patch author='thiago.arrais@gmail.com' date='20060717200939' local_date='Mon Jul 17 17:09:39 BRT 2006' inverted='False' hash='20060717200939-49d33-c04fbb63892ae64cd96d1ad8f1ad2dd0a6e8e7da.gz'>
	<name>Some refactoring after the mess</name>
</patch>
</changelog>
END

  def setup
    @darcs_changes = ''
        
    @darcs_connection = FlexMock.new('darcs connection')

    @darcs_connection.mock_handle(:changes) do
      @darcs_changes
    end

    @reporter = DarcsReporter.new(@darcs_connection)
  end
  
  def test_extracts_info_from_patch_with_title_only
    @darcs_changes = P1
    hl = @reporter.latest_headline
    assert_equal 'thiago.arrais', hl.author
    assert_equal 'Some refactoring after the mess', hl.description
    assert_equal Time.local(2006, 7, 17, 20, 9, 39), hl.happened_at
  end

end

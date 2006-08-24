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

  P2 = <<END
<changelog>
<patch author='thiago.arrais@gmail.com' date='20060813140540' local_date='Sun Aug 13 11:05:40 BRT 2006' inverted='False' hash='20060813140540-49d33-a640b3999077a8be03d81825ad7d40108c827250.gz'>
        <name>Cheking for ghc --make output</name>
        <comment>
Still need testing on Windows. Much probably there are file system and/or
linebreaking issues.</comment>
</patch>
</changelog>
END

  P3 = <<END
<changelog>
<patch author='thiago.arrais@gmail.com' date='20060822135332' local_date='Tue Aug 22 10:53:32 Hora oficial do Brasil 2006' inverted='False' hash='20060822135332-47d7b-f311f9b4f4f2d329d8de62efaa09c5d20cf08f8f.gz'>
	<name> </name>
</patch>
</changelog>
END

  P_EMPTY = <<END
<changelog>
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
    assert_equal '20060717200939-49d33-c04fbb63892ae64cd96d1ad8f1ad2dd0a6e8e7da.gz',
                 hl.rid
    assert_equal 'darcs', hl.reported_by
  end
  
  def test_fetches_headline_details
    @darcs_changes = P1

    rid = '20060717200939-49d33-c04fbb63892ae64cd96d1ad8f1ad2dd0a6e8e7da.gz'
    hl = @reporter.headline(rid)
    
    assert_equal 'thiago.arrais', hl.author
    assert_equal 'Some refactoring after the mess', hl.description
    assert_equal rid, hl.rid
  end
  
  def test_records_long_comment
    @darcs_changes = P2
    
    hl = @reporter.latest_headline
    
    assert_equal "Cheking for ghc --make output\n\n" +
                 "Still need testing on Windows. Much probably there are file system and/or\n" +
                 "linebreaking issues.",    
                 hl.description
  end
  
  def test_empty_change_log
    @darcs_changes = P_EMPTY
    
    hls = @reporter.latest_headlines
    
    assert_equal 0, hls.size
  end
  
  def test_patch_with_empty_title
    @darcs_changes = P3
    
    hl = @reporter.latest_headline
    
    assert_equal 'Untitled patch', hl.description
  end

  #TODO should use the package size when asking the repo connection for xml
  #     input
  #TODO dates are UTC

end

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

require 'darcs_excerpts'
require 'reporters/darcs_reporter'

class DarcsReporterTest  < Test::Unit::TestCase

  def setup
    @darcs_changes = ''
    @darcs_diff = ''
        
    @darcs_connection = FlexMock.new('darcs connection')

    @darcs_connection.mock_handle(:pull).zero_or_more_times
    @darcs_connection.mock_handle(:changes) { @darcs_changes }
    @darcs_connection.mock_handle(:diff) { @darcs_diff }

    @reporter = DarcsReporter.new(@darcs_connection)
  end
  
  def test_extracts_info_from_patch_with_title_only
    @darcs_changes = P1
    hl = @reporter.latest_headline
    assert_equal 'thiago.arrais', hl.author
    assert_equal 'Some refactoring after the mess', hl.description
    assert_equal Time.utc(2006, 7, 17, 20, 9, 39), hl.happened_at
    assert_equal '20060717200939-49d33-c04fbb63892ae64cd96d1ad8f1ad2dd0a6e8e7da',
                 hl.rid
    assert_equal 'darcs', hl.reported_by
  end
  
  def test_fetches_headline_details
    @darcs_changes = P1

    rid = '20060717200939-49d33-c04fbb63892ae64cd96d1ad8f1ad2dd0a6e8e7da'
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
    
    hls = @reporter.latest_headlines('')
    
    assert_equal 0, hls.size
  end
  
  def test_patch_with_empty_title
    @darcs_changes = P3
    
    hl = @reporter.latest_headline
    
    assert_equal 'Untitled patch', hl.description
  end
  
  def test_pulls_before_reporting
    FlexMock.use do |conn|
      conn.should_receive(:pull).once
      conn.should_receive(:changes).returns P_EMPTY
      
      DarcsReporter.new(conn).latest_headlines
    end
  end
  
  def test_multiple_headlines
    @darcs_changes = P4
    
    hls = @reporter.latest_headlines
    
    assert_equal 2, hls.size
    assert_equal 'Some refactoring after the mess', hls[0].title
    assert_equal 'Cheking for ghc --make output', hls[1].title
  end
  
  def test_reads_one_resource_name_and_diff
    @darcs_changes = P5
    @darcs_diff = P5DIFF
    
    hl = @reporter.latest_headlines[0]
    
    assert_equal 1, hl.changes.size

    change = hl.changes[0]
    assert_equal('net.sf.eclipsefp.haskell.ui/src/net/sf/eclipsefp/haskell/ui/preferences/BuildConsolePP.java',
                 change.summary)
    
    assert change.diff.match(/\A@@ -56,18 \+56,36 @@$/)
    assert change.diff.match(/^-			public void widgetDefaultSelected\(SelectionEvent e\) \{\}\n\+			public void widgetDefaultSelected\(SelectionEvent e\) \{/)
    assert change.diff.match(/@Override\n\n/)
  end
  
  def test_reads_more_resource_names_and_diffs
    @darcs_changes = P6
    @darcs_diff = P6DIFF
    
    changes = @reporter.latest_headlines[0].changes
    
    assert_equal 2, changes.size

    assert_equal('net.sf.eclipsefp.common.core/src/net/sf/eclipsefp/common/core/util/MultiplexedWriter.java',
                 changes[0].summary)
    assert_equal('net.sf.eclipsefp.common.core.test/src/net/sf/eclipsefp/common/core/test/util/MultiplexedWriterTest.java',
                 changes[1].summary)

    assert changes[0].diff.match(/\A@@ -1,3 \+1,14 @@$/)
    assert changes[0].diff.match(/^\+\tpublic void removeOutput\(Writer out\) \{$/)
    assert changes[0].diff.match(/^\+\n \}\n/)

    assert changes[1].diff.match(/@@ -76,6 \+76,17 @@/)
    assert changes[1].diff.match(/^\+\t\tmultiplexer.addOutput\(output\);/)
    assert changes[1].diff.match(/Writer multiplexer = new MultiplexedWriter\(outputs\);\n\n/)

  end
  
end

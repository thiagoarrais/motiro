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

class ChangeTest < Test::Unit::TestCase
  
  def test_unset_diff
    assert_nil Change.new(:summary => 'A /directory', :diff => nil).chunked_diff
  end
  
  def test_empty_diff
    assert_nil Change.new(:summary => 'A /directory', :diff => '').chunked_diff
  end
  
  def test_parses_addition_only
    diff_output = "@@ -0,0 +1 @@\n" +
                  "+These are the file_contents"
    change = Change.new(:summary => 'A /a_file.txt', :diff => diff_output)
#    
#    actual_rendered_output = change.render_diff
#    
#    md = actual_rendered_output.match /\A<div id='((\w|\d|-)+)' class='diff-window'><center><h2>Changes to a_file.txt<\/h2>/
#    
#    assert_not_nil md
#    
#    remain = md.post_match
#    
#    md = remain.match /<\/div>\Z/
#    
#    assert_not_nil md
    chunks = change.chunked_diff
    
    assert_equal 1, chunks.size
    assert_equal :addition, chunks.first.action
    assert_equal 1, chunks.first.lines.size
    line = chunks.first.lines.first
    assert_nil line.original_position
    assert_nil line.original_text
    assert_equal 1, line.modified_position
    assert_equal 'These are the file_contents', line.modified_text
  end
  
  def test_passes_lines_numbers_to_differ
    FlexMock.use do |differ|
      differ.should_receive(:start_line).once.with(22, 34)
      differ.should_receive(:get_chunks).once.and_return('chunked diffs')
      differ.should_ignore_missing
      
      change = Change.new(:summary => 'A /a_file.txt',
                          :diff => "@@ -22,0 +34 @@\n" +
                                   "+These are the file_contents")
      
      change.use_differ(differ)
      assert_equal 'chunked diffs', change.chunked_diff
    end
  end
  
  def test_render_summary_with_unset_diff
    change = Change.new(:summary => 'A /directory', :diff => nil)
    
    assert_equal 'A /directory', change.render_summary
  end
  
  def test_render_summary_with_non_empty_diff
    diff_output = "@@ -0,0 +1 @@\n" +
                  "+These are the file_contents"
    change = Change.new(:summary => 'A /a_file.txt', :diff => diff_output)
    
    actual_rendered_output = change.render_summary
    
    md = actual_rendered_output.match /\A<a href='\#' onClick="showOnly\('((\w|\d|-)+)'\)">A \/a_file.txt<\/a>\Z/
    
    assert_not_nil md
  end
  
  def test_simple_prefixed_qualified_resource_name
    change = Change.new(:summary => 'A /a_file.txt')
    assert_equal '/a_file.txt', change.qualified_resource_name
  end
  
  def test_complex_prefixed_qualified_resource_name
    change = Change.new(:summary => 'A /subdir/fileC.txt (from /fileA.txt:2)')
    assert_equal '/subdir/fileC.txt', change.qualified_resource_name
  end
  
  def test_simple_pure_qualified_resource_name
    change = Change.new(:summary => '/directory/a_file.txt')
    assert_equal '/directory/a_file.txt', change.qualified_resource_name
  end

  def test_complex_resource_name
    change = Change.new(:summary => 'A /subdir/fileC.txt (from /fileA.txt:2)')
    assert_equal 'fileC.txt', change.resource_name
  end
  
  def test_file_not_filled
    change = Change.new(:summary => 'A /subdir/fileC.txt',
                        :resource_kind => 'file',
                        :diff => nil)
    
    assert !change.filled?
  end
  
  def test_file_filled
    change = Change.new(:summary => 'A /subdir/fileC.txt',
                        :resource_kind => 'file',
                        :diff => '+file change')
    
    assert change.filled?
  end
  
  def test_directory_always_filled
    change = Change.new(:summary => 'A /subdir',
                        :resource_kind => 'dir',
                        :diff => nil)
    
    assert change.filled?
  end
  
  def test_unknown_always_not_filled
    change = Change.new(:summary => 'A /subdir/fileC.txt',
                        :resource_kind => nil,
                        :diff => '+file change')
    
    assert ! change.filled?
  end
  
end

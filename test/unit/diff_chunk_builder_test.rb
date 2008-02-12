#  Motiro - A project tracking tool
#  Copyright (C) 2006-2008  Thiago Arrais
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
require 'diff_chunk_builder'

class DiffChunkBuilderTest < Test::Unit::TestCase

  def setup
    @builder = DiffChunkBuilder.new
  end

  def test_addition_only
    @builder.push_addition 'I have added this'

    chunks = @builder.get_chunks

    assert_equal 1, chunks.size
    assert !chunks.first.unchanged?
    assert_equal :addition, chunks.first.action
    assert_equal 1, chunks.first.lines.size
    line = chunks.first.lines.first
    assert_nil line.original_position
    assert_nil line.original_text
    assert_equal 1, line.modified_position
    assert_equal 'I have added this', line.modified_text
  end

  def test_deletion_only
    @builder.push_deletion 'I have removed this'

    chunks = @builder.get_chunks

    assert_equal 1, chunks.size
    assert !chunks.first.unchanged?
    assert_equal :deletion, chunks.first.action
    assert_equal 1, chunks.first.lines.size
    line = chunks.first.lines.first
    assert_equal 1, line.original_position
    assert_equal 'I have removed this', line.original_text
    assert_nil line.modified_position
    assert_nil line.modified_text
  end

  def test_matches_alterning_addition_and_deletion
    @builder.push_deletion 'I have removed this'
    @builder.push_addition 'I have added this'

    chunks = @builder.get_chunks

    assert_equal 1, chunks.size
    assert !chunks.first.unchanged?
    assert_equal :modification, chunks.first.action
    assert_equal 1, chunks.first.lines.size
    line = chunks.first.lines.first
    assert_equal 1, line.original_position
    assert_equal 1, line.original_position
    assert_equal 'I have removed this', line.original_text
    assert_equal 1, line.modified_position
    assert_equal 'I have added this', line.modified_text
  end

  def test_multiline_modification
    @builder.push_deletion 'This is the first old line'
    @builder.push_deletion 'This is the second old line'
    @builder.push_addition 'This is the first new line'
    @builder.push_addition 'This is the second new line'

    chunks = @builder.get_chunks

    assert_equal 1, chunks.size
    assert_equal :modification, chunks.first.action
    lines = chunks.first.lines
    assert_equal 2, lines.size
    assert_equal 1, lines.first.original_position
    assert_equal 'This is the first old line', lines.first.original_text
    assert_equal 2, lines.last.original_position
    assert_equal 'This is the second old line', lines.last.original_text
    assert_equal 1, lines.first.modified_position
    assert_equal 'This is the first new line', lines.first.modified_text
    assert_equal 2, lines.last.modified_position
    assert_equal 'This is the second new line', lines.last.modified_text
  end

  def test_more_adds_than_deletes
    @builder.push_deletion  'This is the first old line'
    @builder.push_addition  'This is the first new line'
    @builder.push_addition  'This is the second new line'
    @builder.push_unchanged 'This line remains the same'

    chunks = @builder.get_chunks

    assert_equal 2, chunks.size
    assert_equal :modification, chunks.first.action
    assert_equal :unchanged, chunks.last.action
    assert chunks.last.unchanged?
    lines = chunks.first.lines
    assert_equal 2, lines.size
    assert_equal 1, lines.first.original_position
    assert_equal 'This is the first old line', lines.first.original_text
    assert_nil lines.last.original_position
    assert_nil lines.last.original_text
    assert_equal 1, lines.first.modified_position
    assert_equal 'This is the first new line', lines.first.modified_text
    assert_equal 2, lines.last.modified_position
    assert_equal 'This is the second new line', lines.last.modified_text
    assert_equal 2, chunks.last.lines.first.original_position
    assert_equal 'This line remains the same', chunks.last.lines.first.original_text
    assert_equal 3, chunks.last.lines.first.modified_position
    assert_equal 'This line remains the same', chunks.last.lines.first.modified_text
  end

  def test_less_adds_than_deletes
    @builder.push_deletion 'This is the first old line'
    @builder.push_deletion 'This is the second old line'
    @builder.push_addition 'This is the first new line'
    @builder.push_unchanged 'This line remains the same'

    chunks = @builder.get_chunks

    assert_equal 2, chunks.size
    assert_equal :modification, chunks.first.action
    assert_equal :unchanged, chunks.last.action
    assert chunks.last.unchanged?
    lines = chunks.first.lines
    assert_equal 2, lines.size
    assert_equal 1, lines.first.original_position
    assert_equal 'This is the first old line', lines.first.original_text
    assert_equal 2, lines.last.original_position
    assert_equal 'This is the second old line', lines.last.original_text
    assert_equal 1, lines.first.modified_position
    assert_equal 'This is the first new line', lines.first.modified_text
    assert_nil lines.last.modified_position
    assert_nil lines.last.modified_text
    assert_equal 3, chunks.last.lines.first.original_position
    assert_equal 'This line remains the same', chunks.last.lines.first.original_text
    assert_equal 2, chunks.last.lines.first.modified_position
    assert_equal 'This line remains the same', chunks.last.lines.first.modified_text
  end

  def test_some_code_kept_some_modified
    @builder.start_line 6

    @builder.push_unchanged 'div.channel-title {'
    @builder.push_deletion  '    font: normal 8pt Verdana,sans-serif;'
    @builder.push_addition  '    font: bold 10pt Verdana,sans-serif;'
    @builder.push_unchanged '    margin:0 0 0 0;'

    chunks = @builder.get_chunks
    
    assert_equal 3, chunks.size
    assert chunks[0].unchanged?
    assert_equal :modification, chunks[1].action
    assert chunks[2].unchanged?
    chunks.each { |c| assert_equal 1, c.lines.size }
    assert_equal 6, chunks[0].lines.first.original_position
    assert_equal 'div.channel-title {', chunks[0].lines.first.original_text
    assert_equal 7, chunks[1].lines.first.original_position
    assert_equal '    font: normal 8pt Verdana,sans-serif;', chunks[1].lines.first.original_text
    assert_equal 8, chunks[2].lines.first.original_position
    assert_equal '    margin:0 0 0 0;', chunks[2].lines.first.original_text
    assert_equal 6, chunks[0].lines.first.modified_position
    assert_equal 'div.channel-title {', chunks[0].lines.first.modified_text
    assert_equal 7, chunks[1].lines.first.modified_position
    assert_equal '    font: bold 10pt Verdana,sans-serif;', chunks[1].lines.first.modified_text
    assert_equal 8, chunks[2].lines.first.modified_position
    assert_equal '    margin:0 0 0 0;', chunks[2].lines.first.modified_text
  end

  def test_esparse_changes
    @builder.start_line 6

    @builder.push_unchanged 'div.channel-title {'
    @builder.push_deletion  '    margin:0;'
    @builder.push_deletion  '    font: normal 8pt Verdana,sans-serif;'
    @builder.push_addition  '    font: bold 10pt Verdana,sans-serif;'

    @builder.start_line 13

    @builder.push_addition  '    padding: 0 8px 0 8px;'
    @builder.push_unchanged '}'

    chunks = @builder.get_chunks

    assert_equal 5, chunks.size
    assert chunks[0].unchanged?
    assert_equal :modification, chunks[1].action
    assert chunks[2].separator?
    assert_equal :addition, chunks[3].action
    assert chunks[4].unchanged?
    assert_equal 1, chunks[0].lines.size
    assert_equal 2, chunks[1].lines.size
    assert_equal 4, chunks[2].num_lines
    assert_equal 1, chunks[3].lines.size
    assert_equal 6, chunks[0].lines.first.original_position
    assert_equal 7, chunks[1].lines.first.original_position
    assert_equal 8, chunks[1].lines.last.original_position
    assert_nil chunks[3].lines.first.original_position
    assert_equal 13, chunks[4].lines.first.original_position
    assert_equal 'div.channel-title {', chunks[0].lines.first.original_text
    assert_equal '    margin:0;', chunks[1].lines.first.original_text
    assert_equal '    font: normal 8pt Verdana,sans-serif;', chunks[1].lines.last.original_text
    assert_nil chunks[3].lines.first.original_text
    assert_equal '}', chunks[4].lines.first.original_text

    assert_equal 6, chunks[0].lines.first.modified_position
    assert_equal 7, chunks[1].lines.first.modified_position
    assert_nil chunks[1].lines.last.modified_position
    assert_equal 13, chunks[3].lines.first.modified_position
    assert_equal 14, chunks[4].lines.first.modified_position
    assert_equal 'div.channel-title {', chunks[0].lines.first.modified_text
    assert_equal '    font: bold 10pt Verdana,sans-serif;', chunks[1].lines.first.modified_text
    assert_nil chunks[1].lines.last.modified_text
    assert_equal '    padding: 0 8px 0 8px;', chunks[3].lines.first.modified_text
    assert_equal '}', chunks[4].lines.first.modified_text
  end

  def test_unmatching_line_numbers
    @builder.start_line(6, 6)

    @builder.push_unchanged 'div.channel-title {'
    @builder.push_deletion  '    font: normal 8pt Verdana,sans-serif;'
    @builder.push_addition  '    font: bold 10pt Verdana,sans-serif;'
    @builder.push_addition  '    margin:0 0 0 0;'

    @builder.start_line(13, 14)

    @builder.push_unchanged 'div.channel-body-outer {'
    @builder.push_deletion  '    padding: 0 9px 0 9px;'
    @builder.push_addition  '    padding: 0 8px 0 8px;'
    @builder.push_unchanged '}'

    chunks = @builder.get_chunks

    assert_equal 6, chunks.size
    assert_equal 6, chunks[0].lines.first.original_position
    assert_equal 7, chunks[1].lines.first.original_position
    assert_nil chunks[1].lines.last.original_position
    assert_equal 13, chunks[3].lines.first.original_position
    assert_equal 14, chunks[4].lines.first.original_position
    assert_equal 15, chunks[5].lines.first.original_position

    assert_equal 6, chunks[0].lines.first.modified_position
    assert_equal 7, chunks[1].lines.first.modified_position
    assert_equal 8, chunks[1].lines.last.modified_position
    assert_equal 14, chunks[3].lines.first.modified_position
    assert_equal 15, chunks[4].lines.first.modified_position
    assert_equal 16, chunks[5].lines.first.modified_position
  end
  
#TODO unch unch del
#TODO unch add add unch
#TODO escape html and blank line in view/helper code

end
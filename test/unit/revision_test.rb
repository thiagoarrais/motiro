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

class RevisionTest < Test::Unit::TestCase
  fixtures :users, :pages, :revisions

  def test_revisions_original_author_is_page_original_author
    p = revise_brand_new_page(:title => 'My Title', :text => 'Original content')
    p.revise(john, now, :text => 'Modified content')

    assert_equal bob, p.original_author
    assert_equal bob, p.revisions.first.original_author
    assert_equal bob, p.revisions.last.original_author
  end

  def test_asking_revision_for_revisions_is_the_same_as_asking_parent_page
    rev = revisions('page_creation')
    
    assert_equal rev.page.revisions, rev.revisions
  end
  
  def test_diffs_one_line_modification
    fst_rev = pages('changed_page').revisions[0]
    snd_rev = pages('changed_page').revisions[1]
    
    change_chunks = fst_rev.diff(2)
    assert_equal 1, change_chunks.size
    chunk = change_chunks.first
    assert !chunk.unchanged?
    assert_equal :modification, chunk.action
    assert_equal 1, chunk.lines.size
    line = chunk.lines.first
    assert_equal fst_rev.text, line.original_text
    assert_equal snd_rev.text, line.modified_text 
  end
  
  def test_diffs_all_two_lines_modified
    page = revise_brand_new_page(:title => 'A good page',
                                 :text => "This is the first line\n" +
                                          "And this is the second one")
    page.revise(bob, now, :title => 'A good page',
                          :text => "This is the modified first line\n" +
                                   "And this is the modified second line")
                                   
    chunks = page.revisions[0].diff(2)
    assert_equal 1, chunks.size
    chunk = chunks.first
    assert_equal :modification, chunk.action
    assert_equal 2, chunk.lines.size
    assert_equal 'This is the first line', chunk.lines.first.original_text
    assert_equal 'This is the modified first line', chunk.lines.first.modified_text
    assert_equal 'And this is the second one', chunk.lines.last.original_text
    assert_equal 'And this is the modified second line', chunk.lines.last.modified_text
  end
  
  def test_diffs_with_one_line_unchanged_in_the_middle
    page = revise_brand_new_page(:title => 'A good page',
                                 :text => "This is the first line\n" +
                                          "This line will not be changed\n" +
                                          "And this is the third one")
    page.revise(bob, now, :title => 'A good page',
                          :text => "This is the modified first line\n" +
                                   "This line will not be changed\n" +
                                   "And this is another modification")
                                   
    chunks = page.revisions[0].diff(2)
    assert_equal 3, chunks.size
    assert !chunks[0].unchanged?
    assert_equal :modification, chunks[0].action
    assert  chunks[1].unchanged?
    assert_equal :unchanged, chunks[1].action
    assert !chunks[2].unchanged?
    assert_equal :modification, chunks[2].action
    assert_equal 1, chunks[0].lines.size
    assert_equal 1, chunks[1].lines.size
    assert_equal 1, chunks[2].lines.size
    assert_equal 'This is the first line', chunks[0].lines.first.original_text
    assert_equal 'This is the modified first line', chunks[0].lines.first.modified_text
    assert_equal 'This line will not be changed', chunks[1].lines.first.original_text
    assert_equal 'And this is the third one', chunks[2].lines.first.original_text
    assert_equal 'And this is another modification', chunks[2].lines.first.modified_text
  end
  
  def test_diffs_right_unbalanced_modification
    page = revise_brand_new_page(:title => 'A good page',
                                 :text => "This is the first line\n" +
                                          "This line will not be changed\n" +
                                          "And this is the last one")
    page.revise(bob, now, :title => 'A good page',
                          :text => "This is the modified first line,\n" +
                                   "But I also inserted a new one\n" +
                                   "This line will not be changed\n" +
                                   "And this is the last one")
    chunks = page.revisions[0].diff(2)
    assert_equal 2, chunks.size
    assert !chunks.first.unchanged?
    assert  chunks.last.unchanged?
    assert_equal 2, chunks.first.lines.size
    assert_equal 'This is the first line', chunks.first.lines.first.original_text
    assert_equal 'This is the modified first line,', chunks.first.lines.first.modified_text
    assert_nil chunks.first.lines.last.original_text
    assert_equal 'But I also inserted a new one', chunks.first.lines.last.modified_text
    assert_equal 'This line will not be changed', chunks.last.lines.first.original_text
  end

  def test_diffs_left_unbalanced_modification
    page = revise_brand_new_page(:title => 'A good page',
                                 :text => "This is the first line\n" +
                                          "This line will be removed\n" +
                                          "And this one won't be changed")
    page.revise(bob, now, :title => 'A good page',
                          :text => "This is the modified first line\n" +
                                   "And this one won't be changed")
    chunks = page.revisions[0].diff(2)
    assert_equal 2, chunks.size
    assert_equal 2, chunks.first.lines.size
    assert_equal 'This is the first line', chunks.first.lines.first.original_text
    assert_equal 'This is the modified first line', chunks.first.lines.first.modified_text
    assert_equal 'This line will be removed', chunks.first.lines.last.original_text
    assert_nil chunks.first.lines.last.modified_text
    assert_equal 'And this one won\'t be changed', chunks.last.lines.first.original_text
  end

end

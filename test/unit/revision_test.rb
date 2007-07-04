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

end

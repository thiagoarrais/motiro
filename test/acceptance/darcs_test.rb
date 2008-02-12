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

require 'live_mode_test'
require 'darcs_repo'

class DarcsAcceptanceTest < SeleniumTestCase
  
  include LiveModeTestCase
  
  def create_repository; DarcsRepository.new; end
  def repo_type; 'darcs'; end
  
  def test_shows_comment_title_and_author_on_front_page
    patch_name = 'Created first project file'
    
    @repo.add_file('fileA.txt', 'this is file A')
    @repo.record(patch_name)
    
    open '/'
    
    assert_text_present patch_name
    assert_text_present @repo.author.match(/@/).pre_match
  end
  
  def test_shows_full_text_on_details_page
    patch_title = 'This is the patch title'
    patch_text = patch_title + "\n\n" +
                 "This is a short description of some problems faced when " +
                 "making this patch and some pointers for future investigation"
                 
    @repo.add_file('fileB.txt', 'this is file B')
    @repo.record(patch_text)
    
    open '/'
    
    assert_text_present patch_title
    assert_text_not_present 'This is a short description'
    
    click "//a[text() = '#{patch_title}']"
    wait_for_page_to_load(2000)
    
    assert_equal "Revision details - #{patch_title} (Motiro)", get_title
    assert_text_present 'This is a short description of some problems faced'
    assert_text_present 'for future investigation'
  end
  
end
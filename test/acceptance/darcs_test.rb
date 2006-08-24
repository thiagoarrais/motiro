require 'acceptance/live_mode_test'
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
    
    assert_text_present 'This is a short description of some problems faced'
    assert_text_present 'for future investigation'
  end
  
end
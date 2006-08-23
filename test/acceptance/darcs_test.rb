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
  
end
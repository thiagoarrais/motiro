require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + "/../../vendor/selenium/selenium"

require 'acceptance/live_mode_test'
require 'darcs_repo'

class SubversionAcceptanceTest < SeleniumTestCase
  
  include LiveModeTestCase
  
  def create_repository; DarcsRepository.new; end
  def repo_type; 'darcs'; end
  
  #TODO create a patch and check for the comment and author on the front page
  
end
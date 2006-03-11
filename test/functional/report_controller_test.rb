require File.dirname(__FILE__) + '/../test_helper'
require 'report_controller'

require 'mocks/headline'
require 'stubs/svn_settings'

# Re-raise errors caught by the controller.
class ReportController; def rescue_action(e) raise e end; end

class ReportControllerTest < Test::Unit::TestCase

    fixtures :headlines

    def setup
      @controller = ReportController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end
    
    def test_fetches_headlines_from_cache
      get :show, {:format => 'html_fragment'}
      assert_response :success
      assert_not_nil assigns(:headlines)
      assert_equal 2, assigns(:headlines).size
    end
  
  #TODO what happens if there are no cached headlines?
  #TODO more headlines registered than the package size
  
end

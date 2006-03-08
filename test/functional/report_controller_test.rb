require File.dirname(__FILE__) + '/../test_helper'
require 'report_controller'

# Re-raise errors caught by the controller.
class ReportController; def rescue_action(e) raise e end; end

class ReportControllerTest < Test::Unit::TestCase

  fixtures :headlines

  def setup
    @controller = ReportController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_fetches_headlines_from_cache
    get :subversion
    assert_response :success
    assert_not_nil assigns(:headlines)
    assert_equal 2, assigns(:headlines).size
  end
  
  #TODO what happens if there are no cached headlines?
  
end

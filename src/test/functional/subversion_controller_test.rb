require File.dirname(__FILE__) + '/../test_helper'
require 'subversion_controller'

# Re-raise errors caught by the controller.
class SubversionController; def rescue_action(e) raise e end; end

class SubversionControllerTest < Test::Unit::TestCase
  def setup
    @controller = SubversionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

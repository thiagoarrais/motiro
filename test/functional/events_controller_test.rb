require File.dirname(__FILE__) + '/../test_helper'
require 'events_controller'

# Re-raise errors caught by the controller.
class EventsController; def rescue_action(e) raise e end; end

class EventsControllerTest < Test::Unit::TestCase
  fixtures :headlines

  def setup
    @controller = EventsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_disallow_not_registered_to_add_events
    get :new
    
    assert_redirected_to :controller => 'account', :action => 'login'
    
    post :create

    assert_redirected_to :controller => 'account', :action => 'login'
  end

end

require File.dirname(__FILE__) + '/../test_helper'
require 'events_controller'
require 'test_configuration'

# Re-raise errors caught by the controller.
class EventsController; def rescue_action(e) raise e end; end

class EventsControllerTest < Test::Unit::TestCase

  include TestConfiguration

  fixtures :headlines, :users

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
  
  def test_delegates_creation_to_reporter
    ensure_logged_in
  
    reporter = FlexMock.new
    
    reporter.should_receive(:store_event).
                returns('unimportant').
                once

    @controller = EventsController.new(reporter)
    
    post :create, :headline => unimportant
    
    reporter.mock_verify
  end
  
  def test_fills_author
    ensure_logged_in

    reporter = FlexMock.new
    
    reporter.should_receive(:store_event).
              once.
              returns do |headline|
                author = headline[:author]
                if 'motiro' != author
                  raise Test::Unit::AssertionFailedError.new("wrong author: '#{author}'")
                end
                
                return true
              end
    
    @controller = EventsController.new(reporter)
    
    post :create, :headline => unimportant
    
    reporter.mock_verify
  end
  
  def test_language_routing
    assert_routing( '/', :controller => 'root',
                         :action => 'index',
                         :locale => nil )
    assert_routing( '/events/create', :controller => 'events',
                                      :action => 'create' )
  end
  
private

  def unimportant
    return {:happened_at => Time.local(2006, 04, 26),
            :description => 'uninmportant'}
  end

end

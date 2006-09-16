require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

# Raise errors beyond the default web-based presentation
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < Test::Unit::TestCase
  
  self.use_instantiated_fixtures  = true

  fixtures :users
  
  def setup
    @controller = AccountController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
    @request.host = "localhost"
  end
  
  def test_auth_bob
    @request.session[:return_to] = "/bogus/location"

    login_as 'bob', 'test'
    assert_session_has :user

    assert_equal @bob, @response.session[:user]
    
    assert_redirected_to "/bogus/location"
  end
  
  def test_redirects_to_last_page
    login_as 'bob', 'test', :return_to => '/my/previous/location'

    assert_equal @bob, @response.session[:user]
    assert_redirected_to '/my/previous/location'
  end
  
  def test_no_signup
    begin
        get :signup
        fail 'Should not respond to signup'        
    rescue
        # should happen
    end
  end

  def test_invalid_login
    login_as 'bob', 'not_correct'
     
    assert_session_has_no :user
  end
  
  def test_login_logoff
    login_as 'bob', 'test'
    assert_not_nil session[:user]

    get :logout
    assert_session_has_no :user
  end
  
  def test_signup_and_login
    signup_as 'paul', 'mccartney'
    assert_not_nil session[:user]
    
    get :logout
    assert_session_has_no :user
    
    login_as 'paul', 'mccartney'
    assert_not_nil session[:user]
  end
  
  def test_do_not_allow_signing_up_with_already_used_username
    signup_as 'bob', 'dylan'
    assert_nil session[:user]
    
    assert flash[:username_used]
  end
  
private

  def login_as(login, password, opts={})
    post :login, opts.update(:user => {:login => login, :password => password})
  end
  
  def signup_as(username, password)
    post :signup, :user => { :login => username, :password => password,
                             :password_confirmation => password },
                  :return_to => '/'
  end
  
end

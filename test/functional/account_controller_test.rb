require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

load File.expand_path(File.dirname(__FILE__) + '/../../script/adduser')

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
    post :signup, :user => { :login => 'paul', :password => 'mccartney',
                             :password_confirmation => 'mccartney' },
                  :return_to => '/'
    assert_not_nil session[:user]
    
    get :logout
    assert_session_has_no :user
    
    login_as 'paul', 'mccartney'
    assert_not_nil session[:user]
  end
  
  def test_add_user_script
    adduser('charlie', 'charliessecret', 'charliessecret')
    
    login_as 'charlie', 'charliessecret'
    assert_not_nil session[:user]
  end
  
private

  def login_as(login, password, opts={})
    post :login, opts.update(:user => {:login => login, :password => password})
  end
  
end

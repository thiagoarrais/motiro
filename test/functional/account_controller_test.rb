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

    post :login, :user_login => "bob", :user_password => "test"
    assert_session_has :user

    assert_equal @bob, @response.session[:user]
    
    assert_redirected_to "/bogus/location"
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
    post :login, :user_login => "bob", :user_password => "not_correct"
     
    assert_session_has_no :user
    
    assert_template_has "login"
  end
  
  def test_login_logoff

    post :login, :user_login => "bob", :user_password => "test"
    assert_not_nil session[:user]

    get :logout
    assert_session_has_no :user

  end
  
  def test_add_user_script
    adduser('charlie', 'charliessecret', 'charliessecret')
    
    post :login, :user_login => "charlie", :user_password => "charliessecret"
    assert_not_nil session[:user]
  end
  
end

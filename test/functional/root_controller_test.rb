require File.dirname(__FILE__) + '/../test_helper'
require 'root_controller'

# Re-raise errors caught by the controller.
class RootController; def rescue_action(e) raise e end; end

class RootControllerTest < Test::Unit::TestCase
  def setup
    @controller = RootController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_recognizes_locale_for_only_one_language_on_accept_language
     @request.env['HTTP_ACCEPT_LANGUAGE'] = 'pt-BR'
     get :index
     
     assert_equal('pt-BR', assigns(:locale))
     assert_equal('pt-BR', Locale.active.code)
  end
  
  def test_url_with_locale_takes_precedence
     @request.env['HTTP_ACCEPT_LANGUAGE'] = 'pt-BR'
     get :index, { :locale => 'de' }

     assert_equal('de', assigns(:locale))
     assert_equal('de', Locale.active.code)
  end
  
  #TODO recognize multiple-language list

end

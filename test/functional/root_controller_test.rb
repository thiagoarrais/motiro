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

  def test_routes_language_specified_on_url
    assert_routing('/en', :controller => 'root',
                          :action => 'index',
                          :locale => 'en')
  end
  
  def test_routes_to_nil_locale_when_language_not_specified
    assert_routing('/',   :controller => 'root',
                          :action => 'index',
                          :locale => nil)
  end
  
  def test_recognizes_locale_for_only_one_language_on_accept_language
     @request.env['HTTP_ACCEPT_LANGUAGE'] = 'pt-BR'
     get :index
     
     assert_equal('pt-BR', assigns(:locale))
     assert_equal('pt-BR', Locale.active.code)
  end
  
  def test_recognizes_locale_for_multiple_language_request
     @request.env['HTTP_ACCEPT_LANGUAGE'] = 'pt-br,en-us;q=0.5'
     get :index
     
     assert_equal('pt-br', assigns(:locale))
     assert_equal('pt-br', Locale.active.code)
  end

  def test_url_with_locale_takes_precedence
     @request.env['HTTP_ACCEPT_LANGUAGE'] = 'pt-BR'
     get :index, { :locale => 'de' }

     assert_equal('de', assigns(:locale))
     assert_equal('de', Locale.active.code)
  end
  
  def test_recognizes_locale_when_quality_specified
     @request.env['HTTP_ACCEPT_LANGUAGE'] = 'pt-br;q=1,en-us;q=0.5'
     get :index
     
     assert_equal('pt-br', assigns(:locale))
     assert_equal('pt-br', Locale.active.code)
  end
  
  def test_invalid_language_code_defaults_to_english
     @request.env['HTTP_ACCEPT_LANGUAGE'] = '7h'

     get :index
     
     assert_equal('en-US', assigns(:locale))
     assert_equal('en-US', Locale.active.code)
  end
  
  def test_uses_last_language_when_language_not_specified
     @request.env['HTTP_ACCEPT_LANGUAGE'] = 'fr'
     get :index

     assert_equal('fr', Locale.active.code)

     @request.env['HTTP_ACCEPT_LANGUAGE'] = nil
     get :index, { :locale => 'de' }

     assert_equal('de', Locale.active.code)
     
     get :index
     
     assert_equal('de', assigns(:locale))
     assert_equal('de', Locale.active.code)
  end
  
  def test_uses_last_specified_language_when_accept_language_differs
     get :index, { :locale => 'sw' }
     
     assert_equal('sw', Locale.active.code)
     
     @request.env['HTTP_ACCEPT_LANGUAGE'] = 'pt-BR'
     get :index
     
     assert_equal('sw', assigns(:locale))
     assert_equal('sw', Locale.active.code)
  end
  
  def test_defaults_to_english_when_not_otherwise_specified
    get :index
    
    assert_equal('en-US', assigns(:locale))
    assert_equal('en-US', Locale.active.code)
  end
  
  def test_empty_language_string_on_accept_language_means_nothing
    @request.env['HTTP_ACCEPT_LANGUAGE'] = ''
    get :index
    
    assert_equal('en-US', assigns(:locale))
    assert_equal('en-US', Locale.active.code)
  end
  
  #TODO check the HTTP spec for the Accept-Language header format

end

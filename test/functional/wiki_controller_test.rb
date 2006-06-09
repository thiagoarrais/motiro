require File.dirname(__FILE__) + '/../test_helper'
require 'wiki_controller'
require 'test_configuration'

# Re-raise errors caught by the controller.
class WikiController; def rescue_action(e) raise e end; end

class WikiControllerTest < Test::Unit::TestCase

  include TestConfiguration

  def setup
    @controller = WikiController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_wiki_routing
    assert_routing('/wiki/edit/MainPage', :controller => 'wiki',
                                          :action => 'edit',
                                          :page => 'MainPage')
  end

  def test_language_routing
    assert_routing('/en', :controller => 'root',
                          :action => 'index',
                          :locale => 'en')
    assert_routing('/',   :controller => 'root',
                          :action => 'index')
    assert_routing('/wiki/show/MainPage/en', :controller => 'wiki',
                                             :action => 'show',
                                             :page => 'MainPage',
                                             :locale => 'en')
  end

  def test_asks_page_provider_for_pages_when_editing
    FlexMock.use do |page_provider|
      page_provider.should_receive(:find_by_name).
          with('TestPage').
          once.
          and_return(Page.new(:name => 'TestPage',
                                :text => ''))
      @controller = WikiController.new(page_provider)

      ensure_logged_in
      get :edit, {:page => 'TestPage'}
      assert_response :success
    end
  end
  
  def test_authentication_required_for_edition
     get :edit, { :page => 'TestPage' }
     assert_redirected_to(:controller => 'account', :action => 'login')
  end
  
  def test_askes_page_to_render_in_specific_language
    FlexMock.use('provider', 'page') do |provider, page|
        provider.should_receive(:find_by_name).
          with_any_args.
          and_return(page).
          once
        page.should_receive(:render_html).
          with('en').
          and_return("<div>You've been mocked!").
          once
        
        @controller = WikiController.new(provider)

        get :show, {:page => 'TestPage', :locale => 'en'}
        assert_response :success
     end
  end
  
  def test_askes_page_to_render_in_default_language
    FlexMock.use('provider', 'page') do |provider, page|
        provider.should_receive(:find_by_name).
          with_any_args.
          and_return(page).
          once
        page.should_receive(:render_html).
          with(nil).
          and_return("<div>You've been mocked!</div>").
          once
        
        @controller = WikiController.new(provider)

        get :show, {:page => 'TestPage'}
        assert_response :success
     end
  end
  
end

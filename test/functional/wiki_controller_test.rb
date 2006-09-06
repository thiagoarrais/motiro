require File.dirname(__FILE__) + '/../test_helper'
require 'wiki_controller'
require 'test_configuration'

# Re-raise errors caught by the controller.
class WikiController; def rescue_action(e) raise e end; end

class WikiControllerTest < Test::Unit::TestCase

  include TestConfiguration
  
  fixtures :users, :pages

  def setup
    @controller = WikiController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_routes_to_nil_locale_when_not_specified_on_url
    assert_routing('/wiki/edit/MainPage', :controller => 'wiki',
                                          :action => 'edit',
                                          :page_name => 'MainPage')
  end

  def test_routes_to_specified_locale_page
    assert_routing('/wiki/show/MainPage/en', :controller => 'wiki',
                                             :action => 'show',
                                             :page_name => 'MainPage',
                                             :locale => 'en')
  end
  
  def test_blocks_edition
    @request.session[:user] = users('bob')
    
    page_name = pages('johns_page').name
    
    get :edit, { :page_name => page_name }
    assert_redirected_to :action => 'show', :page_name => page_name
  end
  
  def test_blocks_saving_pages_for_unauthorized_users
    @request.session[:user] = users('john')
  
    page_name = pages('bob_and_erics_page').name
    
    post :save, { :page_name => page_name,
                  :page => { :text => 'New text',
                             :editors => 'john' },
                  'btnSave' => true }
    
    assert flash[:not_authorized]
    assert_redirected_to :action => 'show', :page_name => page_name
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
      get :edit, {:page_name => 'TestPage'}
      assert_response :success
    end
  end
  
  def test_authentication_required_for_edition
     get :edit, { :page_name => 'TestPage' }
     assert_redirected_to(:controller => 'account', :action => 'login')
  end
  
  #TODO block editors list changing for direct post
  #TODO think about and write a test for stealthy manipulation of author field
  
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

        get :show, {:page_name => 'TestPage', :locale => 'en'}
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

        get :show, {:page_name => 'TestPage'}
        assert_response :success
     end
  end
  
end

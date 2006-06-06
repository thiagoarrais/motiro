require File.dirname(__FILE__) + '/../test_helper'
require 'wiki_controller'

# Re-raise errors caught by the controller.
class WikiController; def rescue_action(e) raise e end; end

class WikiControllerTest < Test::Unit::TestCase
  def setup
    @controller = WikiController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_routing
    assert_routing('/wiki/edit/MainPage', :controller => 'wiki',
                                          :action => 'edit',
                                          :page => 'MainPage')
  end

  def test_asks_page_provider_for_pages_when_editing
    FlexMock.use do |page_provider|
      page_provider.should_receive(:find_by_name).
          with('TestPage').
          once.
          and_return(Page.new(:name => 'TestPage',
                                :text => ''))
      @controller = WikiController.new(page_provider)

      get :edit, {:page => 'TestPage'}
      assert_response :success
    end
  end

end

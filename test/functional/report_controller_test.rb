require File.dirname(__FILE__) + '/../test_helper'
require 'report_controller'

require 'rubygems'

require 'flexmock'

require 'mocks/headline'
require 'stubs/svn_settings'

# Re-raise errors caught by the controller.
class ReportController; def rescue_action(e) raise e end; end

class ReportControllerTest < Test::Unit::TestCase

    self.use_instantiated_fixtures  = true

    fixtures :headlines, :articles
    
    def setup
        @controller = ReportController.new
        @request    = ActionController::TestRequest.new
        @response   = ActionController::TestResponse.new
    end
    
    def test_fetches_headlines_from_cache
        get :show, {:format => 'html_fragment'}
        assert_response :success
        assert_not_nil assigns(:headlines)
        assert_equal @headlines.size, assigns(:headlines).size
    end
    
    def test_fetches_individual_article_based_on_headline_id
        get :show, {:format => 'html_fragment', :id => 1}
        assert_response :success
        assert_not_nil assigns(:article)
    end
    
    def test_calling_show_with_an_id_delegates_to_chief_editor
        FlexMock.use do |editor|
            editor.should_receive(:article_for_headline).with(3).
                returns(articles('svn_demo_article')).
                once
                
            @controller = ReportController.new(editor)
            
            get :show, {:id => 3}
        end
    end

  #TODO what happens if there are no cached headlines?
  #TODO more headlines registered than the package size
  
end

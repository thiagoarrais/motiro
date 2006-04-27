require File.dirname(__FILE__) + '/../test_helper'
require 'report_controller'

require 'rubygems'

require 'flexmock'

require 'mocks/headline'
require 'stubs/svn_settings'

# Re-raise errors caught by the controller.
class ReportController; def rescue_action(e) raise e end; end

class ReportControllerTest < Test::Unit::TestCase
  
  fixtures :headlines
  
  def setup
    @controller = ReportController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_fetches_headlines_from_cache
    get :show, {:reporter => 'events', :format => 'html_fragment'}
    assert_response :success
    assert_not_nil assigns(:headlines)
    expected = Headline.find(:all, :conditions => "reported_by = 'events'")
    assert_equal expected.size, assigns(:headlines).size
  end
  
  def test_fetches_individual_headline_based_on_rid
    svn_demo_headline = headlines('svn_demo_headline')
    get :show, { :format => 'html_fragment',
                 :reporter => svn_demo_headline.reported_by,
                 :id => svn_demo_headline.rid }
    assert_response :success
    assert_not_nil assigns(:headline)
  end
  
  def test_calling_show_with_an_id_delegates_to_chief_editor
    FlexMock.use do |editor|
      editor.should_receive(:headline_with).with('subversion', '3').
        returns(headlines('svn_demo_headline')).
        once
      
      @controller = ReportController.new(editor)
      
      get :show, {:reporter => 'subversion', :id => 3}
    end
  end
  
  def test_calling_show_with_invalid_rid_redirects_to_index
    get :show, { :reporter => 'subversion', :id => 'r300' }
    assert_equal 'Não foi possível encontrar o artigo r300 do repórter Subversion', flash[:notice]
    assert_redirected_to :controller => 'root', :action => 'index'
  end
  
  def test_renders_with_appropriate_template
    svn_demo_headline = headlines('svn_demo_headline')
    reporter_name = svn_demo_headline.reported_by
    get :show, { :reporter => reporter_name,
                 :id => svn_demo_headline.rid }
    
    assert_template "report/#{reporter_name}_detail"
    
    release_event = headlines('release_event')
    reporter_name = release_event.reported_by
    get :show, { :reporter => reporter_name,
                 :id => release_event.rid }
    
    assert_template "report/#{reporter_name}_detail"
  end
  
  #TODO what happens if there are no cached headlines?
  #TODO more headlines registered than the package size
  
end

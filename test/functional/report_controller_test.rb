#  Motiro - A project tracking tool
#  Copyright (C) 2006-2007  Thiago Arrais
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

require File.dirname(__FILE__) + '/../test_helper'
require 'report_controller'

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
    get :list, { :reporter => 'subversion' }
    assert_response :success
    assert_not_nil assigns(:headlines)
    expected = Headline.find(:all, :conditions => "reported_by = 'subversion'")
    assert_equal expected.size, assigns(:headlines).size
  end
  
  def test_routes_localized_feeds
    assert_routing('/feed/subversion/en-gb',
                   :controller => 'report', :action => 'rss',
                   :reporter => 'subversion', :locale => 'en-gb' )
  end
  
  def test_fetches_individual_headline_based_on_rid
    svn_demo_headline = headlines('svn_demo_headline')
    get :show, { :reporter => svn_demo_headline.reported_by,
                 :id => svn_demo_headline.rid }
    assert_response :success
    assert_not_nil assigns(:headline)
  end
  
  def test_calling_show_with_an_id_delegates_to_chief_editor
    FlexMock.use do |editor|
      editor.should_receive(:reporter_with).with('subversion').
        and_return(nil)
      editor.should_receive(:headline_with).with('subversion', '3').
        returns(headlines('svn_demo_headline')).
        once
      
      @controller = ReportController.new(editor)
      
      get :show, {:reporter => 'subversion', :id => 3}
    end
  end
  
  def test_calling_show_with_invalid_rid_redirects_to_index
    get :show, { :reporter => 'subversion', :id => 'r300' }
    assert_equal 'The article r300 from the Subversion reporter could not be found', flash[:notice]
    assert_redirected_to :controller => 'root', :action => 'index'
  end
  
  def test_include_headline_date_on_guid
    gita = headlines('gita')
    
    get :rss, { :reporter => gita.reported_by }
    
    assert_xml_element "//guid[contains(text(), '#{gita.happened_at.strftime('%Y%m%d%H%M%S')}')]"
  end
  
  #TODO what happens if there are no cached headlines?
  #TODO more headlines registered than the package size
  
private

  def assert_template(expected)
    assert_equal File.expand_path("#{__FILE__}/../../../app/views/#{expected}.rhtml"),
                 File.expand_path(@response.rendered_file)
  end
  
end

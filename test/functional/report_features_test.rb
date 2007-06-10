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

# Re-raise errors caught by the controller.
class ReportController; def rescue_action(e) raise e end; end

class ReportFeaturesTest < Test::Unit::TestCase
  
  fixtures :pages

  def setup
    @controller = ReportController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_links_to_feature_pages_from_rss_feed
    get :list, :reporter => 'features', :locale => 'en', :format => 'xml'
    assert_xml_element "//link[text() = 'http://test.host/wiki/show/ListLastModifiedFeatures']"
  end
  
end

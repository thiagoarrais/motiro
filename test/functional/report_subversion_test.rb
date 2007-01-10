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
require 'live_mode_test'

# Re-raise errors caught by the controller.
class ReportController; def rescue_action(e) raise e end; end

class ReportSubversionTest < Test::Unit::TestCase
  include LiveModeTestCase
  
  def do_setup
    @controller = ReportController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_report_rss
    commit_title = 'Created my project'
    commit_msg = "#{commit_title}\n" +
                     "\n" +
                     "This revision creates a brand new directory where we \n" +
                     "will keep our project files"
    
    @repo.mkdir('myproject', commit_msg)
    
    get :rss, :reporter => 'subversion'
    assert_xml_element("//rss/channel/title[text() = 'Motiro - Subversion']")
    assert_xml_element("//rss/channel/generator[text() = 'Motiro']")
    assert_xml_element("//rss/channel/item/title[text() = '#{commit_title}']")
    assert_xml_element("//rss/channel/item/description[contains(text(), 'This revision creates')]")
    assert_xml_element("//rss/channel/item/*[local-name() = 'creator' and text() = '#{@repo.username}']")
  end

  def test_translates_rss_feed
    english_msg = "I changed something in the source code repository"
    portuguese_msg = "Mudei algo no repositorio de codigo fonte"
    commit_msg = english_msg + "\n\n--- pt-br ----\n\n" + portuguese_msg
    
    @repo.mkdir('myproject', commit_msg)
    
    get :rss, :reporter => 'subversion', :locale => 'en'
    assert_xml_element("//rss/channel/item/title[text() = '#{english_msg}']")
    assert_no_xml_element("//rss/channel/item/title[text() = '#{portuguese_msg}']")

    get :rss, :reporter => 'subversion', :locale => 'pt-br'
    assert_xml_element("//rss/channel/item/title[text() = '#{portuguese_msg}']")
    assert_no_xml_element("//rss/channel/item/title[text() = '#{english_msg}']")
  end
  
end

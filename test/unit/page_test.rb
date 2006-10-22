#  Motiro - A project tracking tool
#  Copyright (C) 2006  Thiago Arrais
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

class PageTest < Test::Unit::TestCase
  fixtures :pages

  def test_renders_title
    page = Page.new
    page.text = '= Motiro ='
    expected_text = "<h1>Motiro</h1>"
    assert_equal expected_text, page.render_html
  end
  
  def test_breaks_paragraphs_on_linebreak_and_return_feed
    line_break_page = Page.new(:text => "= Motiro =\n\nThis is project Motiro")
    return_page = Page.new(:text => "= Motiro =\r\n\r\nThis is project Motiro")
    expected_text = '<h1>Motiro</h1><p>This is project Motiro</p>'
    assert_equal expected_text, line_break_page.render_html
    assert_equal expected_text, return_page.render_html
  end
  
  def test_render_external_links
    page = Page.new(:text => '[http://nowhere.com Nowhere]')
    expected = "<p><a href=\"http://nowhere.com\" rel=\"nofollow\">Nowhere</a></p>"
    assert_equal expected, page.render_html
  end
  
  def test_renders_multiple_languages
    page = Page.new
    page.text = "Bem-vindo ao Motiro\n\n" +
                "--- en ---\n" +
                "Welcome to Motiro"
    assert_equal "<p>Bem-vindo ao Motiro</p>", page.render_html
    assert_equal "<p>Welcome to Motiro</p>",
                 page.render_html('en')
  end
  
  def test_is_open_to_all
    attrs = { :name => 'SomePage', :text => 'Page text' }
    assert !Page.new(attrs.merge(:editors => 'john')).is_open_to_all?
    assert  Page.new(attrs.merge(:editors => '')).is_open_to_all?
    assert  Page.new(attrs.merge(:editors => '  ')).is_open_to_all?
    assert !Page.new(attrs.merge(:editors => '  john ')).is_open_to_all?
    assert  Page.new(attrs.merge(:editors => "\n")).is_open_to_all?
  end
  
  def test_fresh_page_is_open_to_all
    page = Page.new(:name => 'FreshPage')
    
    assert page.is_open_to_all?
  end
  
  def test_fresh_page_has_empty_editors_list
    page = Page.new(:name => 'AnotherFreshPage')
    
    assert_equal 0, page.editors.size
  end

end

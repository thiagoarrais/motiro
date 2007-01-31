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

require 'stubs/url_generator' 

class WikiRendererTest < Test::Unit::TestCase

  attr_reader :renderer
  
  def setup
    @renderer = WikiRenderer.new(url_generator)
  end

  def test_renders_title
    assert_equal "<h1>Motiro</h1>", renderer.render_html('= Motiro =')
  end
  
  def test_breaks_paragraphs_on_linebreak_and_return_feed
    line_break_only_text = "= Motiro =\n\nThis is project Motiro"
    feed_return_text = "= Motiro =\r\n\r\nThis is project Motiro"
    expected_text = '<h1>Motiro</h1><p>This is project Motiro</p>'

    assert_equal expected_text, renderer.render_html(line_break_only_text)
    assert_equal expected_text, renderer.render_html(feed_return_text)
  end
  
  def test_render_external_links
    expected = "<p><a href=\"http://nowhere.com\" rel=\"nofollow\">Nowhere</a></p>"
    assert_equal expected, renderer.render_html('[http://nowhere.com Nowhere]')
  end
  
  def test_renders_multiple_languages
    wiki_text = "Bem-vindo ao Motiro\n\n" +
                "--- en ---\n" +
                "Welcome to Motiro"
    assert_equal "<p>Bem-vindo ao Motiro</p>", renderer.render_html(wiki_text)
    assert_equal "<p>Welcome to Motiro</p>",
                 WikiRenderer.new(url_generator, 'en').render_html(wiki_text)
  end
  
  def test_renders_internal_link
    expected = "<p><a href=\"http://test.host/wiki/show/AnotherPage\" rel=\"nofollow\">go somewhere else</a></p>"
    assert_equal expected, renderer.render_html('[AnotherPage go somewhere else]')
  end
  
  def test_renders_multiple_internal_links
    expected = "<p><a href=\"http://test.host/wiki/show/InternalPage\" rel=\"nofollow\">go there</a> <a href=\"http://test.host/wiki/show/OtherInternalPage\" rel=\"nofollow\">and there</a></p>"
    assert_equal expected, renderer.render_html("[InternalPage go there] " +
                                                "[OtherInternalPage and there]")
  end

private

  def url_generator; TestingUrlGenerator.new; end
  
end
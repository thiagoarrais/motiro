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
    assert_equal "<h1>Motiro</h1>", renderer.render_wiki_text('= Motiro =')
  end
  
  def test_breaks_paragraphs_on_linebreak_and_return_feed
    line_break_only_text = "= Motiro =\n\nThis is project Motiro"
    feed_return_text = "= Motiro =\r\n\r\nThis is project Motiro"
    expected_text = '<h1>Motiro</h1><p>This is project Motiro</p>'

    assert_equal expected_text, renderer.render_wiki_text(line_break_only_text)
    assert_equal expected_text, renderer.render_wiki_text(feed_return_text)
  end
  
  def test_render_external_links
    expected = "<p><a href=\"http://nowhere.com\" rel=\"nofollow\">Nowhere</a></p>"
    assert_equal expected, renderer.render_wiki_text('[http://nowhere.com Nowhere]')
  end
  
  def test_renders_multiple_languages
    wiki_text = "Bem-vindo ao Motiro\n\n" +
                "--- en ---\n" +
                "Welcome to Motiro"
    assert_equal "<p>Bem-vindo ao Motiro</p>", renderer.render_wiki_text(wiki_text)
    assert_equal "<p>Welcome to Motiro</p>",
                 WikiRenderer.new(url_generator, 'en').render_wiki_text(wiki_text)
  end
  
  def test_renders_internal_link
    expected = "<p><a href=\"http://test.host/wiki/show/AnotherPage\" rel=\"nofollow\">go somewhere else</a></p>"
    assert_equal expected, renderer.render_wiki_text('[AnotherPage go somewhere else]')
  end
  
  def test_renders_multiple_internal_links
    expected = "<p><a href=\"http://test.host/wiki/show/InternalPage\" rel=\"nofollow\">go there</a> <a href=\"http://test.host/wiki/show/OtherInternalPage\" rel=\"nofollow\">and there</a></p>"
    assert_equal expected, renderer.render_wiki_text("[InternalPage go there] " +
                                                     "[OtherInternalPage and there]")
  end
  
  def test_do_not_expand_links_when_there_is_a_break_inside_the_brackets
    expected = "<p>[ThisIsNotALink\nto anywhere]</p>"
    assert_equal expected, renderer.render_wiki_text("[ThisIsNotALink\nto anywhere]")
  end
  
  def test_expands_internal_links_with_address_only
    expected = "<p><a href=\"http://test.host/wiki/show/AnotherPage\" rel=\"nofollow\">AnotherPage</a></p>"
    assert_equal expected, renderer.render_wiki_text("[AnotherPage]")
  end
  
  def test_recover_from_unmatched_opening_bracket_inside_link_text
    assert_equal "<p><a href=\"http://test.host/wiki/show/SomeoneMistankenly\" rel=\"nofollow\">placed an opening bracket [ inside the link text, but Motiro managed to recover correctly</a></p>",
                 renderer.render_wiki_text("[SomeoneMistankenly placed an opening bracket [ inside the link text, but Motiro managed to recover correctly]")
  end
  
  def test_emphasizes_diffs_inside_pure_text_change
    previous = "There is going to be some change inside this text"
    current  = "There has been some change inside this text"
    
    assert_equal '<p>There <span class="deletion">is going to be</span>' +
                 '<span class="addition">has been</span> some change inside ' +
                 'this text</p>',
                 renderer.render_wiki_diff(previous, current)
  end
  
  def test_emphasizes_diffs_in_multiple_changes
    previous = "There is going to be more than one change inside this text"
    current  = "There has been more than one change outside this text"
    
    assert_equal '<p>There <span class="deletion">is going to be</span>' +
                 '<span class="addition">has been</span> more than one ' +
                 'change <span class="deletion">inside</span>' +
                 '<span class="addition">outside</span> ' +
                 'this text</p>',
                 renderer.render_wiki_diff(previous, current)
  end
  
  def test_emphasizes_changes_next_to_html_tags
    previous = "First version was good"
    current = "Second version was bad"
    
    assert_equal '<p><span class="deletion">First</span>' +
                 '<span class="addition">Second</span> version was ' +
                 '<span class="deletion">good</span>' +
                 '<span class="addition">bad</span></p>',
                 renderer.render_wiki_diff(previous, current)
  end

  def test_emphasizes_changes_inside_html_tags
    previous = "Some ''long emphasized'' text"
    current = "Some ''short emphasized'' text"
    
    assert_equal '<p>Some <i><span class="deletion">long</span>' +
                 '<span class="addition">short</span> emphasized</i>  text</p>',
                 renderer.render_wiki_diff(previous, current)
  end

  def test_emphasizes_changes_to_html_tags
    previous = "Some ''emphasized'' text"
    current = "Some '''emphasized''' text"
    
    assert_equal '<p>Some <span class="deletion"><i>emphasized</i></span>' +
                 '<span class="addition"><b>emphasized</b></span> text</p>',
                 renderer.render_wiki_diff(previous, current)
  end

  def test_emphasizes_changes_inside_partially_changed_html_tags
    previous = "Here is a [http://www.motiro.org link]"
    current = "Here is a [http://www.motiro.com link]"
    
    assert_equal '<p>Here is a <span class="deletion"><a href="http://www.motiro.org" rel="nofollow">link</a></span>' +
                 '<span class="addition"><a href="http://www.motiro.com" rel="nofollow">link</a></span></p>',
                 renderer.render_wiki_diff(previous, current)
  end
  
  def test_emphasizes_changed_html_tags_after_changed_text
    previous = "Here is my ''long text''"
    current = "Here is your ''long article''"

    assert_equal '<p>Here is <span class="deletion">my</span>' +
                 '<span class="addition">your</span> ' +
                 '<i>long <span class="deletion">text</span>' +
                 '<span class="addition">article</span></i> ' +
                 '</p>',
                 renderer.render_wiki_diff(previous, current)
  end

  def test_emphasizes_changed_html_tags_before_changed_text
    previous = "Here is some ''long text'' that is yours"
    current = "Here is some ''long article'' that is mine"

    assert_equal '<p>Here is some ' +
                 '<i>long <span class="deletion">text</span>' +
                 '<span class="addition">article</span></i>  ' +
                 'that is <span class="deletion">yours</span>' +
                 '<span class="addition">mine</span>' +
                 '</p>',
                 renderer.render_wiki_diff(previous, current)
  end

  def test_emphasizes_line_breaked_changes_as_one
    previous = "This is a\nmultiline change"
    current = "This is an\nenvious change"
    
    assert_equal '<p>This is <span class="deletion">a multiline</span>' +
                 '<span class="addition">an envious</span> change</p>',
                 renderer.render_wiki_diff(previous, current)
  end

  def test_emphasizes_text_deletions
    previous = "Here is something deleted"
    current = "Here is something"

    assert_equal '<p>Here is something <span class="deletion">deleted</span></p>',
                 renderer.render_wiki_diff(previous, current)
  end

  def test_emphasizes_text_additions
    previous = "Here is something"
    current = "Here is the place I added something"

    assert_equal '<p>Here is <span class="addition">the place I added</span> something</p>',
                 renderer.render_wiki_diff(previous, current)
  end
  
  def test_emphasizes_addition_and_deletions_inside_tags
    previous = "Here is some ''text in italics''"
    current = "Here is some ''very good text''"
    
    assert_equal '<p>Here is some <i><span class="addition">very good</span> ' +
                 'text <span class="deletion">in italics</span></i> </p>',
                 renderer.render_wiki_diff(previous, current)
  end

private

  def url_generator; TestingUrlGenerator.new; end
  
end
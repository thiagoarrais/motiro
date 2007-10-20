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

  fixtures :pages, :revisions
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
    expected = "<p><a href=\"http://nowhere.com\">Nowhere</a></p>"
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
    assert_equal "<p><a href=\"http://test.host/wiki/show/AnotherPage\">go somewhere else</a></p>",
                 renderer.render_wiki_text('[[AnotherPage|go somewhere else]]')
  end
  
  def test_renders_multiple_internal_links
    assert_equal "<p><a href=\"http://test.host/wiki/show/InternalPage\">go there</a> <a href=\"http://test.host/wiki/show/OtherInternalPage\">and there</a></p>",
                 renderer.render_wiki_text("[[InternalPage|go there]] " +
                                           "[[OtherInternalPage|and there]]")
  end
  
  def test_do_not_expand_links_when_there_is_a_break_inside_the_brackets
    expected = "<p>[ThisIsNotALink\nto anywhere]</p>"
    assert_equal expected, renderer.render_wiki_text("[ThisIsNotALink\nto anywhere]")
  end
  
  def test_expands_internal_links_with_address_only
    expected = "<p><a href=\"http://test.host/wiki/show/AnotherPage\">AnotherPage</a></p>"
    assert_equal expected, renderer.render_wiki_text("[[AnotherPage]]")
  end
  
  def test_recover_from_unmatched_opening_bracket_inside_link_text
    assert_equal "<p><a href=\"http://test.host/wiki/show/SomeoneMistankenly\">placed an opening bracket [ inside the link text, but Motiro managed to recover correctly</a></p>",
                 renderer.render_wiki_text("[[SomeoneMistankenly|placed an opening bracket [ inside the link text, but Motiro managed to recover correctly]]")
  end
  
  def test_emphasizes_diffs_inside_pure_text_change
    previous = "There is going to be some change inside this text"
    current  = "There has been some change inside this text"
    
    assert_equal '<p>There <span style="background: #ffb8b8">is going to be</span>' +
                 '<span style="background: #b8ffb8">has been</span> some change inside ' +
                 'this text</p>',
                 renderer.render_wiki_diff(previous, current)
  end
  
  def test_emphasizes_diffs_in_multiple_changes
    previous = "There is going to be more than one change inside this text"
    current  = "There has been more than one change outside this text"
    
    assert_equal '<p>There <span style="background: #ffb8b8">is going to be</span>' +
                 '<span style="background: #b8ffb8">has been</span> more than one ' +
                 'change <span style="background: #ffb8b8">inside</span>' +
                 '<span style="background: #b8ffb8">outside</span> ' +
                 'this text</p>',
                 renderer.render_wiki_diff(previous, current)
  end
  
  def test_emphasizes_changes_next_to_html_tags
    previous = "First version was good"
    current = "Second version was bad"
    
    assert_equal '<p><span style="background: #ffb8b8">First</span>' +
                 '<span style="background: #b8ffb8">Second</span> version was ' +
                 '<span style="background: #ffb8b8">good</span>' +
                 '<span style="background: #b8ffb8">bad</span></p>',
                 renderer.render_wiki_diff(previous, current)
  end

  def test_emphasizes_changes_inside_html_tags
    previous = "Some ''long emphasized'' text"
    current = "Some ''short emphasized'' text"
    
    assert_equal '<p>Some <i><span style="background: #ffb8b8">long</span>' +
                 '<span style="background: #b8ffb8">short</span> emphasized</i> text</p>',
                 renderer.render_wiki_diff(previous, current)
  end

  def test_emphasizes_changes_to_html_tags
    previous = "Some ''emphasized'' text"
    current = "Some '''emphasized''' text"
    
    assert_equal '<p>Some <i><span style="background: #ffb8b8">emphasized</span></i>' +
                 '<b><span style="background: #b8ffb8">emphasized</span></b> text</p>',
                 renderer.render_wiki_diff(previous, current)
  end

  def test_emphasizes_changes_inside_partially_changed_html_tags
    previous = "Here is a [http://www.motiro.org link]"
    current = "Here is a [http://www.motiro.com link]"
    
    assert_equal '<p>Here is a <a href="http://www.motiro.org"><span style="background: #ffb8b8">link</span></a>' +
                 '<a href="http://www.motiro.com"><span style="background: #b8ffb8">link</span></a></p>',
                 renderer.render_wiki_diff(previous, current)
  end
  
  def test_emphasizes_changed_html_tags_after_changed_text
    previous = "Here is my ''long text''"
    current = "Here is your ''long article''"

    assert_equal '<p>Here is <span style="background: #ffb8b8">my</span>' +
                 '<span style="background: #b8ffb8">your</span> ' +
                 '<i>long <span style="background: #ffb8b8">text</span>' +
                 '<span style="background: #b8ffb8">article</span></i>' +
                 '</p>',
                 renderer.render_wiki_diff(previous, current)
  end

  def test_emphasizes_changed_html_tags_before_changed_text
    previous = "Here is some ''long text'' that is yours"
    current = "Here is some ''long article'' that is mine"

    assert_equal '<p>Here is some ' +
                 '<i>long <span style="background: #ffb8b8">text</span>' +
                 '<span style="background: #b8ffb8">article</span></i> ' +
                 'that is <span style="background: #ffb8b8">yours</span>' +
                 '<span style="background: #b8ffb8">mine</span>' +
                 '</p>',
                 renderer.render_wiki_diff(previous, current)
  end

  def test_emphasizes_line_breaked_changes_as_one
    previous = "This is a\nmultiline change"
    current = "This is an\nenvious change"
    
    assert_equal '<p>This is <span style="background: #ffb8b8">a multiline</span>' +
                 '<span style="background: #b8ffb8">an envious</span> change</p>',
                 renderer.render_wiki_diff(previous, current)
  end

  def test_emphasizes_text_deletions
    previous = "Here is something deleted"
    current = "Here is something"

    assert_equal '<p>Here is something <span style="background: #ffb8b8">deleted</span></p>',
                 renderer.render_wiki_diff(previous, current)
  end

  def test_emphasizes_text_additions
    previous = "Here is something"
    current = "Here is the place I added something"

    assert_equal '<p>Here is <span style="background: #b8ffb8">the place I added</span> something</p>',
                 renderer.render_wiki_diff(previous, current)
  end
  
  def test_emphasizes_addition_and_deletions_inside_tags
    previous = "Here is some ''text in italics''"
    current = "Here is some ''very good text''"
    
    assert_equal '<p>Here is some <i><span style="background: #b8ffb8">very good</span> ' +
                 'text <span style="background: #ffb8b8">in italics</span></i></p>',
                 renderer.render_wiki_diff(previous, current)
  end
  
  def test_emphasizes_paragraph_addition_and_deletion
    previous = "First paragraph\n\nSecond paragraph"
    current  = "Second paragraph\n\nThird paragraph"
    
    assert_equal '<p><span style="background: #ffb8b8">First paragraph</span></p> ' +
                 '<p>Second paragraph</p> ' +
                 '<p><span style="background: #b8ffb8">Third paragraph</span></p>',
                 renderer.render_wiki_diff(previous, current)
  end
  
  def test_emphasize_change_inside_title_tag
    previous = "== Sub title ==\n\nParagraph"
    current  = "== Super title ==\n\nParagraph"
    
    assert_equal '<h2><span style="background: #ffb8b8">Sub</span>' +
                 '<span style="background: #b8ffb8">Super</span> title</h2> ' +
                 '<p>Paragraph</p>',
                 renderer.render_wiki_diff(previous, current)
  end

  def test_emphasize_change_inside_composite_tag
    previous = "* This is a list\n" +
               "* With three items\n" +
               "** One of them is a nested list\n" +
               "** With two items"
    current  = "* This is a list\n" +
               "* With three items\n" +
               "** One of them is another list\n" +
               "** With two changed items"

    assert_equal '<ul>' +
                   "<li>This is a list\n</li> " +
                   '<li>With three items ' +
                   '<ul>' +
                     '<li>One of them is ' +
                       '<span style="background: #ffb8b8">a nested</span>' +
                       '<span style="background: #b8ffb8">another</span> list</li> ' +
                     '<li>With two <span style="background: #b8ffb8">changed</span> items</li>' +
                   '</ul></li>' +
                 '</ul>',
                 renderer.render_wiki_diff(previous, current)
  end

  # should fail for the time being
  def test_marks_references_to_finished_features
    name = pages('finished_feature').name
    assert_equal "<p>Yada yada yada <a class=\"done\" href=\"http://test.host/wiki/show/#{name}\">#{name}</a></p>",
                 renderer.render_wiki_text('Yada yada yada [[FinishedFeature]]')
  end

private

  def url_generator; TestingUrlGenerator.new; end
  
end

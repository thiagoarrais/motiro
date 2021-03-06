#  Motiro - A project tracking tool
#  Copyright (C) 2006-2008  Thiago Arrais
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

class StringExtensionsTest < Test::Unit::TestCase

  def test_medialize
    str = "= Motiro =\n\nAnother paragraph"
    assert_equal "<h1><a name='Motiro'></a> Motiro </h1><p>\n\n</p><p>Another paragraph</p>",
                 str.medialize
  end

  def test_xml_splits_simple_elements
    str = "<p>This is a paragraph</p><p>And another one</p>"
    assert_equal ['<p>This is a paragraph</p>', '<p>And another one</p>'],
                 str.xml_split
  end

  def test_xml_splits_elements_with_attributes
    str = 'This is a paragraph with a <a href="http://www.motiro.org/">link</a> inside'
    assert_equal ['This', 'is', 'a', 'paragraph', 'with', 'a',
                  '<a href="http://www.motiro.org/">link</a>', 'inside'], str.xml_split
  end
  
  def test_xml_splits_tag_with_line_break
    str = "<p>This is a\nmultiline change</p>"
    assert_equal ["<p>This is a\nmultiline change</p>"], str.xml_split
  end
  
  def test_xml_splits_multiletter_tags
    str = '<h2>Level 2 title</h2><p>Paragraph</p>'
    assert_equal ['<h2>Level 2 title</h2>', '<p>Paragraph</p>'], str.xml_split
  end

  def test_xml_splits_nested_identical_tags
    str = '<ul><li>a b</li><li>c <ul><li>d e f</li><li>g h</li></ul></li></ul>'+
          '<p>paragraph</p>'
    assert_equal ['<ul><li>a b</li><li>c <ul><li>d e f</li><li>g h</li></ul></li></ul>',
                  '<p>paragraph</p>'], str.xml_split
  end

  def test_xml_splits_empty_element
   assert_equal ["<a name='Sub_title'/>", 'Sub', 'title'],
                "<a name='Sub_title'/> Sub title ".xml_split
  end
end

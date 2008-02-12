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
require 'array_extensions'

class ArrayExtensionsTest < Test::Unit::TestCase

  def test_xml_joins_enclosing_elements
    words = ['<p>', 'This', 'is', 'a', 'paragraph', '</p>']
    assert_equal '<p>This is a paragraph</p>', words.xml_join
  end
  
  def test_xml_joins_inline_elements_with_spaces
    words = ['<p>', 'A', '<a href="http://www.motiro.org">', 'link', '</a>',
             'here', '</p>']
    assert_equal '<p>A <a href="http://www.motiro.org">link</a> here</p>',
                 words.xml_join
  end
  
  def test_xml_joins_empty_strings
    words = ['<p>A paragraph</p>', '']
    assert_equal '<p>A paragraph</p>', words.xml_join
  end

end

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

class DefaultPageProviderTest < Test::Unit::TestCase

  def setup
    @provider = DefaultPageProvider.new    
  end
  
  def test_nil_type_creates_common_page
    assert_equal Page, @provider.find_by_name_and_type('MainPage', nil).class
  end
  
  def test_event_type_creates_event_page
    klass = @provider.find_by_name_and_type('MainPage', 'Event').class
    assert_equal Event, klass
  end
  
  def test_provides_congratulations_page_for_main_page
    page_text = @provider.find_by_name_and_type('MainPage', nil).text
    assert page_text.match(/Congratulations/)
  end

  def test_provides_you_can_edit_this_page_for_random_pages
    page_text = @provider.find_by_name_and_type('AnyPage', nil).text
    assert page_text.match(/nothing to be read here/)
    assert page_text.match(/But you can write something right now/)
  end

end
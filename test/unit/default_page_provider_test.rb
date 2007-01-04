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
  
  def test_provides_congratulations_page_for_main_page
    assert @provider.find_by_name('MainPage').text.match(/Congratulations/)
  end

  def test_provides_you_can_edit_this_page_for_random_pages
    page_text = @provider.find_by_name('AnyPage').text
    assert page_text.match(/nothing to be read here/)
    assert page_text.match(/But you can write something right now/)
  end

end
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

  def test_delegates_retrieval_to_decorated_provider
    FlexMock.use('provider') do |provider|
      provider.should_receive(:find_by_name).
       with('MainPage').
       returns(:page).
       once

      assert_equal :page,
                   DefaultPageProvider.new(provider).find_by_name('MainPage')
    end
  end

  def test_provides_an_empty_page_when_decorated_provider_cant_find_one
    FlexMock.use('provider') do |provider|
      provider.should_receive(:find_by_name).
        with('RandomPage').
        returns(nil).
        once

      page = DefaultPageProvider.new(provider).find_by_name('RandomPage')
      assert page.text.match(/nothing to be read here/)
      assert page.text.match(/But you can write something right now/)
    end
  end

end

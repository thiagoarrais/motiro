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

class WikiLinkHandlerTest < Test::Unit::TestCase

  def test_delegates_generation_to_controller
    FlexMock.use do |cont|
      cont.should_receive(:server_url_for).once.returns('a').
        with(:controller => 'wiki', :action => 'show', :page_name => 'MyPage')
      
      assert_equal 'a', WikiLinkHandler.new(cont).url_for('MyPage')
    end
  end

end

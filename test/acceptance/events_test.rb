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

require 'live_mode_test'

class EventsAcceptanceTest < AcceptanceTestCase
  
  fixtures :users, :headlines
  
  def test_no_error_on_development_mode
    open '/report/events/en'
    assert_text_present 'Scheduled events'
  end
  
  def test_event_addition_disabled_without_authentication
    open('/en')
    assert_element_present "//span[@class = 'disabled' and text() = 'Add']"
  end
    
  def test_edition_enabled_when_authenticated
    #TODO refactor this to a declarative style
    #see http://www.testing.com/cgi-bin/blog/2005/12/19
    log_as(:bob)
        
    assert_element_present "//div[@id='events']//a[text() = 'Add']"

    click "//div[@id='events']//a[text() = 'Add']"
    wait_for_page_to_load(1500)
    
    assert_element_present "//select/option[text() = '2007']"
  end
 
end

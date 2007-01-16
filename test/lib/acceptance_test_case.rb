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

require File.dirname(__FILE__) + "/../../vendor/selenium/selenium"

require 'selenium_extensions'

class AcceptanceTestCase < SeleniumTestCase

  include SeleniumExtensions

  TEST_PASSWORDS = { :bob => 'test', :john => 'lennon', :eric => 'clapton',
                     :existingbob => 'test', :longbob => 'longtest' }
  
  def log_as(user, passwd=nil)
    open('/en')

    type('user_login', user.to_s)
    type('user_password', passwd || TEST_PASSWORDS[user])
    
    click 'login'
    wait_for_page_to_load(2000)
  end
  
  def log_out
    open '/account/logout'  
  end

end
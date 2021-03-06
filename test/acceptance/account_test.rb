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
require 'acceptance_test_case'

class AccountAcceptanceTest < AcceptanceTestCase
  
  fixtures :users
  fixtures :headlines
  
  def test_welcomes_user
    log_as(:bob)
    assert_text_present 'Welcome, bob'
  end
  
  def test_switches_languages_when_logged_in
    log_as(:bob)
    
    assert_text_present 'Welcome, bob'
    assert_element_present "//a[text() = 'Edit']"
    
    click "//a[@id='pt-BR']"
    wait_for_page_to_load(1500)
    
    assert_text_present 'Bem-vindo, bob'
    assert_element_present "//a[text() = 'Editar']"
  end
  
  def test_registering_new_user
    open '/en'
    
    assert_text_present 'New user?'
    assert_not_visible "//label[@for='user_password_confirmation']"
    assert_not_visible 'id=user_password_confirmation'
    
    click 'chk_new_user'
    
    assert_visible "//label[@for='user_password_confirmation']"
    assert_visible 'id=user_password_confirmation'
    
    click 'chk_new_user'
    
    assert_not_visible "//label[@for='user_password_confirmation']"
    assert_not_visible 'id=user_password_confirmation'
    
    click 'chk_new_user'
    
    type 'user_login', 'paul'
    type 'user_password', 'mccartney'
    type 'user_password_confirmation', 'mccartney'
    
    click 'login'
    wait_for_page_to_load(1500)
    
    assert_text_present 'Welcome, paul'
    
    log_out
    log_as(:paul, 'mccartney')
    
    assert_text_present 'Welcome, paul'
  end
  
  def test_register_existing_user
    open '/'
    
    click 'chk_new_user'
    type 'user_login', 'eric'
    sleep 1
    wait_for_condition "selenium.page().findElement('id=username_not_available')", 1000
  end
  
  def test_do_not_show_error_tooltip_when_not_registering_new_user
    open '/'
    
    type 'user_login', 'eric'
    sleep 1
    assert_element_not_present 'id=username_not_available'
  end
  
  def test_edition_disabled_without_authentication
    open('/en')
    assert_element_present "//span[contains(text(), 'requires authentication') and @class = 'disabled']"
  end
  
  def test_edition_enabled_when_authenticated
    #TODO refactor this to a declarative style
    #see http://www.testing.com/cgi-bin/blog/2005/12/19
    log_as(:bob)
    
    assert_location 'exact:http://localhost:3000/en'
    
    assert_element_present "//a[text() = 'Edit']"
    click "//a[text() = 'Edit']"
    
    wait_for_page_to_load(1000)
    
    assert_element_present "//input[@name='btnSave']"
    assert_element_present "//input[@name='btnDiscard']"
    assert_element_present "//textarea[@id='txaEditor']"
  end
  
  def test_returns_to_previous_page_after_logged_in
    gita = headlines('gita')
    open "/show/#{gita.reported_by}/#{gita.rid}"
    
    assert_text_present gita.description
    
    type 'user_login', 'bob'
    type 'user_password', 'test'
    click 'login'
    wait_for_page_to_load 1500
    
    assert_location "exact:http://localhost:3000/show/#{gita.reported_by}/#{gita.rid}"
    assert_text_present gita.description
  end
  
  def test_shows_passwords_do_not_match_warning
    open '/'
    
    click 'chk_new_user'
    
    type 'user_login', 'neil'
    type 'user_password', 'young'
    sleep 1.2
    
    assert_not_visible 'id=passwords_do_not_match'
    
    type 'user_password_confirmation', 'youmg'
    sleep 1.2

    assert_visible 'id=passwords_do_not_match'
  end
  
  def test_signout_redirects_to_previous_page
    log_as(:bob)
    
    click 'signout'
    wait_for_page_to_load 1500
    
    assert_location "exact:http://localhost:3000/en"
  end
  
  def test_login_failure_shows_error_on_main_page
    check_if_login_failure_shows_error_on_page('/', 'Latest news from Subversion')
  end
  
  def test_login_failure_shows_error_on_other_pages
    rid = headlines('gita').rid
    check_if_login_failure_shows_error_on_page(
      "/show/subversion/#{rid}",
      "Revision #{rid}")
  end
  
private

  def check_if_login_failure_shows_error_on_page(addr, text)
    open(addr)

    assert_text_not_present('Incorrect username or password')

    type('user_login', 'failure')
    type('user_password', 'invalid')
    click('login')
    
    wait_for_page_to_load(1500)
    
    assert_text_present(text)
    assert_text_present('Incorrect username or password')
  end

end
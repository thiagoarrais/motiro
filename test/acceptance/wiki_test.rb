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

require 'acceptance/live_mode_test'

class WikiAcceptanceTest < SeleniumTestCase

  fixtures :users, :pages
  
  def test_edit_main_page
    open '/en'
    type 'user_login', 'bob'
    type 'user_password', 'test'
    
    click 'login'
    wait_for_page_to_load(1000)
    
    click "//a[text() = 'Edit']"
    wait_for_page_to_load(1000)
    
    type 'txaEditor', "= Motiro =\n\nThis is project motiro."
    click 'btnSave'
    
    wait_for_page_to_load(1000)
    
    assert_element_present "//h1[text() = 'Motiro']"
    assert_text_present 'This is project motiro'
  end
  
  def test_translates_edition_page
    open '/en'
    
    type 'user_login', 'bob'
    type 'user_password', 'test'
    
    click 'login'
    wait_for_page_to_load(1500)
    
    click "//a[text() = 'Edit']"
    wait_for_page_to_load(1500)
    
    assert_equal 'Save modifications', get_attribute('btnSave@value')
    assert_equal 'Discard', get_attribute('btnDiscard@value')
    
    assert_text_present 'Quick reference'
    assert_text_present 'Title: = Title ='
    assert_text_present 'Link: [address label]'
    
    click "pt-BR"
    wait_for_page_to_load(1500)
    
    assert /Salvar modifica/ =~ get_attribute('btnSave@value')
    assert_equal 'Descartar', get_attribute('btnDiscard@value')
    
    assert_text_present 'Refer'
    assert_text_present 'ncia r'
    assert_text_present 'tulo'
    assert_text_present 'Link'
    assert_text_present '[endere'
    assert_text_present 'o r'
    assert_text_present 'tulo]'
  end
  
  def test_does_not_save_modifications_when_discard_button_pressed
    open '/en'
    
    type 'user_login', 'bob'
    type 'user_password', 'test'
    
    click 'login'
    wait_for_page_to_load(1500)
    
    click "//a[text() = 'Edit']"
    wait_for_page_to_load(1500)
    
    type 'txaEditor', "= This title does not show =\n\n" +
                      "Neither does this text"
    
    click 'btnDiscard'
    wait_for_page_to_load(1500)
    
    assert_location 'exact:http://localhost:3000/'
    
    assert_text_not_present 'This title does not show'
  end
  
  def test_blocks_edition_for_unauthorized_users
    open '/en'
    
    type 'user_login', 'bob'
    type 'user_password', 'test'
    
    click 'login'
    wait_for_page_to_load(1500)
    
    open '/wiki/edit/TestPage'
    
    type 'txaEditor', 'Original Text'
    type 'txtAuthorized', 'bob eric'
    click 'btnSave'
    wait_for_page_to_load(1500)
    
    open '/account/logout'
    open '/en'
    
    type 'user_login', 'john'
    type 'user_password', 'lennon'
    
    click 'login'
    wait_for_page_to_load(1500)
    
    open '/wiki/show/TestPage'
    assert_text_present 'Edit (not authorized)'
    
    open '/wiki/edit/TestPage'
    assert get_text("//span[@class = 'marked']").match(/\(not authorized\)/)
  end
  
  def test_original_author_can_change_authorization_list
    open '/en'

    type 'user_login', 'bob'
    type 'user_password', 'test'
    
    click 'login'
    wait_for_page_to_load(1500)
    
    open '/wiki/edit/' + pages('bob_and_erics_page').name
    
    type 'txtAuthorized', 'bob eric john'
    click 'btnSave'
    wait_for_page_to_load(1500)
    
    open '/account/logout'
    open '/en'
    
    type 'user_login', 'john'
    type 'user_password', 'lennon'
    
    click 'login'
    wait_for_page_to_load(1500)
    
    open '/wiki/edit/' + pages('bob_and_erics_page').name
    assert_element_present 'txaEditor'
  end
  
  def test_only_original_author_can_change_authorization_list
    open '/en'

    type 'user_login', 'eric'
    type 'user_password', 'clapton'
    
    click 'login'
    wait_for_page_to_load(1500)
    
    open '/wiki/edit/' + pages('bob_and_erics_page').name
    assert_element_present 'txaEditor'
    assert_element_not_present 'txtAuthorized'
  end
  
  def test_records_original_author_for_pages_without_author
    open '/en'

    type 'user_login', 'bob'
    type 'user_password', 'test'
    
    click 'login'
    wait_for_page_to_load(1500)

    edition_page = '/wiki/edit/' + pages('nobodys_page').name
    open edition_page
    
    assert_element_present 'txtAuthorized'
    
    type 'txaEditor', 'New edited text for Nobody\'s Page'
    click 'btnSave'
    wait_for_page_to_load(1500)
    
    open '/account/logout'

    open '/en'

    type 'user_login', 'john'
    type 'user_password', 'lennon'
    
    click 'login'
    wait_for_page_to_load(1500)

    open edition_page

    assert_element_not_present 'txtAuthorized'
  end
  
  def test_describing_feature_adds_to_main_page_channel
    open '/en'

    type 'user_login', 'bob'
    type 'user_password', 'test'
    
    click 'login'
    wait_for_page_to_load(2000)

    feature_title = 'Tagging wiki pages as feature suggestions'
    
    open '/wiki/new/feature'
    
    type 'txtTitle', feature_title
    type 'txaEditor', 'Maybe being able to tag some wiki pages as feature suggestions will be a good idea'
    
    click 'btnSave'
    wait_for_page_to_load(2000)
    
    open '/en'
    
    assert_text_present feature_title         
  end
  
  def test_links_to_recently_changed_features_on_main_page
    open '/en'
    
    list_page = pages('list_last_modified_features_page')
    assert_element_present "//a[text() = '#{list_page.title}']"
    click "//a[text() = '#{list_page.title}']"
    wait_for_page_to_load(2000)
    
    assert_text_present list_page.title
    assert_text_present list_page.text
  end

end
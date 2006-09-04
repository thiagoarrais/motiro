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
    
    assert_equal 'Motiro', get_text('//h1')
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
  
  #TODO only original author can change authorization list
  
end
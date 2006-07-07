require 'acceptance/live_mode_test'

class SubversionAcceptanceTest < SeleniumTestCase
  
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
  
end
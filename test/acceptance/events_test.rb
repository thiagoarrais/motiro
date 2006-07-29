require 'acceptance/live_mode_test'

class EventsAcceptanceTest < SeleniumTestCase
  
  include LiveModeTestCase
  
  fixtures :users
  
  def setup
    Headline.destroy_all
  end
  
  def test_no_error_on_development_mode
    open '/report/events?locale=en'
    assert_text_present 'Upcoming events'
  end
  
  def test_create_event_and_show_headline
    open '/en'
    type 'user_login', 'bob'
    type 'user_password', 'test'
    
    click 'login'
    
    event_title = "Let's celebrate the success of another release"
    
    open '/events/new'
    type 'txaEditor', event_title + "\n\n" +
                                 "Our next release will be awesome! " +
                                 "Let's get together somewhere to celebrate"
    select 'headline[happened_at(3i)]', '26'
    select 'headline[happened_at(2i)]', 'value=4'
    select 'headline[happened_at(1i)]', '2006'
    
    click 'btnSave'
    wait_for_page_to_load 5000
    
    assert_location 'exact:http://localhost:3000/'
    
    assert_text_present event_title
  end
  
  def test_show_event_details
    test_create_event_and_show_headline
    
    event_title = "Let's celebrate the success of another release"
    event_description = "Our next release will be awesome! " +
                        "Let's get together somewhere to celebrate"
    click "//a[text() = \"#{event_title}\"]"    
    wait_for_page_to_load 1000
    
    assert_text_present event_title
    assert_text_present event_description
  end
  
  #TODO test not logged can't create events
  
  def test_translates_event_details_page
    test_create_event_and_show_headline
    
    event_title = "Let's celebrate the success of another release"
    click "//a[text() = \"#{event_title}\"]"    
    wait_for_page_to_load(2000)

    click "//a[@id='en']"
    wait_for_page_to_load(1000)
    
    assert_equal 'Motiro - Event', get_title

    click "//a[@id='pt-BR']"
    wait_for_page_to_load(1000)

    assert_equal 'Motiro - Evento', get_title
  end
  
  def test_translates_event_creation_page
    open '/account/login'
    type 'user_login', 'bob'
    type 'user_password', 'test'
    
    click 'login'

    open '/events/new?locale=en'
    
    assert_equal 'Motiro - Events', get_title
    
    assert_equal 'Save modifications', get_attribute('btnSave@value')
    assert_equal 'Discard', get_attribute('btnDiscard@value')

    assert_text_present 'Date'
    assert_text_present 'Note'
    assert_text_present 'The first line on the event text will turn into a ' +
                        'summary displayed on the main page'

    open '/events/new?locale=pt-BR'

    assert_equal 'Motiro - Eventos', get_title

    assert /Salvar modifica/ =~ get_attribute('btnSave@value')
    assert_equal 'Descartar', get_attribute('btnDiscard@value')

    assert_text_present 'Data'
    assert_text_present 'Observa'
    assert_text_present 'A primeira linha do texto do evento ser'
    assert_text_present 'exibida como resumo na p'
    assert_text_present 'gina principal'
  end
  
  def test_first_line_on_event_description_becomes_main_page_summary
    open '/en'
    type 'user_login', 'bob'
    type 'user_password', 'test'
    
    click 'login'
  
    open '/events/new?locale=en'
    
    event_title = 'This is the event summary'
    type 'txaEditor', event_title + "\n\n" +
                      "And here comes the detailed description"

    select 'headline[happened_at(3i)]', '26'
    select 'headline[happened_at(2i)]', 'value=7'
    select 'headline[happened_at(1i)]', '2006'
    
    click 'btnSave'
    wait_for_page_to_load(2000)
    
    assert_text_not_present 'And here comes the detailed description'
    click "//a[text() = \"#{event_title}\"]"
    wait_for_page_to_load(2000)
    
    assert_text_present 'And here comes the detailed description'
  end
  
  def test_translates_event
    open '/en'
    type 'user_login', 'bob'
    type 'user_password', 'test'
    
    click 'login'
  
    open '/events/new?locale=en'
    
    english_title = 'Eighth release'
    english_description = "Our eighth release, with version number 0.5, should be comming out sometime " +
                          "in August. This will be the first version with a sketch of the feature " +
                          "voting system."
    portuguese_title = 'Oitavo release'
    portuguese_description = "Nosso oitavo release, com numero de versao 0.5, deve estar disponivel em algum ponto " +
                             "de agosto. Esta serah a primeira versao com uma previa do sistema de votacao."
    type 'txaEditor', english_title + "\n\n" + english_description +
                      "\n\n--- pt-br ----------\n\n" +
                      portuguese_title + "\n\n" + portuguese_description

    select 'headline[happened_at(3i)]', '21'
    select 'headline[happened_at(2i)]', 'value=8'
    select 'headline[happened_at(1i)]', '2006'
    
    click 'btnSave'
    wait_for_page_to_load(2000)
    
    assert_text_not_present portuguese_title
    click "//a[text() = \"#{english_title}\"]"
    wait_for_page_to_load(2000)
    
    assert_text_present english_description
    assert_text_not_present portuguese_title
    assert_text_not_present portuguese_description
    
    click "//a[@id='pt-BR']"
    wait_for_page_to_load(2000)
    
    assert_text_present portuguese_description 
    assert_text_not_present english_title
    assert_text_not_present english_description
    
    open "/pt-BR"
    
    assert_text_present portuguese_title
    assert_text_not_present english_title
  end
  
  def test_render_events_as_wiki_text
    open '/en'
    type 'user_login', 'bob'
    type 'user_password', 'test'
    
    click 'login'
  
    open '/events/new'
    
    title = 'This is the event title'
    first_paragraph = 'This is the first paragraph'
    second_paragraph = 'This is the second paragraph'
    type 'txaEditor', title + "\n\n" +
                      first_paragraph + "\n\n" +
                      second_paragraph
    
    click 'btnSave'
    wait_for_page_to_load(2000)
    
    click "//a[text() = \"#{title}\"]"
    wait_for_page_to_load(2000)
    
    assert_element_present "//p[text() = \"#{first_paragraph}\"]"
    assert_element_present "//p[text() = \"#{second_paragraph}\"]"
  end

  def teardown
    Headline.destroy_all
  end
  
end

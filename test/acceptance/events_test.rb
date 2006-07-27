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
    open '/account/login'
    type 'user_login', 'bob'
    type 'user_password', 'test'
    
    click 'login'
    
    event_title = "Let's celebrate the success of another release"
    
    open '/events/new'
    type 'headline_title', event_title
    select 'headline[happened_at(3i)]', '26'
    select 'headline[happened_at(2i)]', 'value=4'
    select 'headline[happened_at(1i)]', '2006'
    type 'headline_description', "Our next release will be awesome\n" +
                                 "Let's get together somewhere to celebrate"
    
    click 'commit'
    wait_for_page_to_load 5000
    
    assert_location 'exact:http://localhost:3000/'
    
    assert_text_present event_title
  end
  
  def test_show_event_details
    test_create_event_and_show_headline
    
    event_title = "Let's celebrate the success of another release"
    event_description = "Our next release will be awesome\n" +
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
    
    assert_text_present 'New event'
    assert_text_present 'Summary'
    assert_text_present 'Date'
    assert_text_present 'Description'
    assert_equal 'Create', get_attribute("commit@value")

    open '/events/new?locale=pt-BR'

    assert_equal 'Motiro - Eventos', get_title

    assert_text_present 'Novo evento'
    assert_text_present 'tulo' # Título
    assert_text_present 'Data'
    assert_text_present 'Descri' # Descrição
    assert_equal 'Criar', get_attribute("commit@value")
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

  def teardown
    Headline.destroy_all
  end
  
end

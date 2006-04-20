require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + "/../../vendor/selenium/selenium"

require 'acceptance/live_mode_test'

class EventsAcceptanceTest < Test::Unit::TestCase

    include LiveModeTestCase

    fixture :users

    def test_no_error_on_development_mode
        open '/report/events'
        assert_text_present 'ximos eventos'
    end
    
    def test_create_event_and_show_headline
        open '/account/login'
        type 'user_login', 'bob'
        type 'user_password', 'test'
        
        click 'login'
    
        open '/events/create'

        event_title = "Let's celebrate the success of another release"
        open '/fake_events_create.html'
        type 'title', event_title
        select 'date_day', '26'
        select 'date_month', '04'
        select 'date_year', '2006'
        type 'description', "Our next release will be awesome\n" +
                            "Let's get together somewhere to celebrate"
        click 'add_event'

        assert_location '/'

        assert_text_present event_title
    end
    
    #TODO test not logged can't create events
    
end

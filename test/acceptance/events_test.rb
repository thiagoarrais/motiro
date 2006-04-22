require 'acceptance/live_mode_test'

class EventsAcceptanceTest < Test::Unit::TestCase

    include LiveModeTestCase

    fixtures :users

    def setup
        Headline.destroy_all
    end

    def test_no_error_on_development_mode
        open '/report/events'
        assert_text_present 'ximos eventos'
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
        wait_for_page_to_load 1000

        assert_location '/'
        
        assert_text_present event_title
    end
    
    def teardown
        Headline.destroy_all
    end
    
    #TODO test not logged can't create events
    
end

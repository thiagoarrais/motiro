require 'acceptance/live_mode_test'

class MotiroAcceptanceTest < Test::Unit::TestCase

    include LiveModeTestCase

    def do_setup
        @sel = Selenium::SeleneseInterpreter.new("localhost", 4444,
                        "*firefox", "http://localhost:3000", 15000)
        @sel.start
    end
  
    def test_no_error_on_development_mode
        @sel.open '/report/events'
        @sel.assert_text_present 'ximos eventos'
    end
    
    def do_teardown
        @sel.stop
    end

end

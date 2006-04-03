require 'acceptance/live_mode_test'

class MotiroAcceptanceTest < Test::Unit::TestCase

    include LiveModeTestCase

    def test_no_error_on_development_mode
        open '/report/events'
        assertTextPresent 'Próximos eventos'
    end

end
require 'test/unit'

class MockSubversionReporter

    include Test::Unit::Assertions

    def expect_latest_headlines(&action)
        @action = action
    end
    
    def latest_headlines
        @latest_headlines_called = true
        @action.call
    end
    
    def verify
        assert @latest_headlines_called
    end

end
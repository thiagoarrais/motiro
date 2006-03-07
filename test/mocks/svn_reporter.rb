require 'test/unit'

class MockSubversionReporter

    include Test::Unit::Assertions

    def expect_latest_headlines(num, &action)
        @expected_num = num
        @action = action
    end
    
    def latest_headlines(num)
        @latest_headlines_called = true
        assert_equal @expected_num, num
        @action.call
    end
    
    def verify
        assert @latest_headlines_called
    end

end
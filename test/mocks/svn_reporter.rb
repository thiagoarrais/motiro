require 'test/unit'

class MockSubversionReporter

    include Test::Unit::Assertions

    def initialize
        @actual_times_latest_headlines_called = 0
        @expected_times_latest_headlines_called = 0
    end

    def expect_latest_headlines(&action)
        @action = action if block_given?
        @expected_times_latest_headlines_called += 1
    end
    
    def latest_headlines
        @actual_times_latest_headlines_called += 1
        @latest_headlines_called = true
        @action.call
    end
    
    def verify
        assert @latest_headlines_called
        assert_equal @expected_times_latest_headlines_called,
               @actual_times_latest_headlines_called
    end
    
end
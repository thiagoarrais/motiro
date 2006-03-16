require 'test/unit'

require 'core/reporter'

class MockSubversionReporter < MotiroReporter

    include Test::Unit::Assertions

    def initialize
        super('subversion')
        @actual_times_latest_headlines_called = 0
        @expected_times_latest_headlines_called = 0
    end

    def expect_latest_headlines(&action)
        @action = action if block_given?
        @expected_times_latest_headlines_called += 1
    end
    
    def latest_headlines
        @actual_times_latest_headlines_called += 1
        @action.call
    end
    
    def verify
        assert_equal @expected_times_latest_headlines_called,
               @actual_times_latest_headlines_called
    end
    
end
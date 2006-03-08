require 'test/unit'

require 'models/headline'

class MockHeadline < Headline

    include Test::Unit::Assertions

    def initialize
        @expected_times_save_called = 0
        @actual_times_save_called = 0
    end

    def expect_save
        @expected_times_save_called += 1
    end
    
    def save
        @actual_times_save_called += 1
    end
    
    def verify
        assert_equal @expected_times_save_called, @actual_times_save_called
    end

end
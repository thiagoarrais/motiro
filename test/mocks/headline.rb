require 'test/unit'

require 'models/headline'

class MockHeadline < Headline

    include Test::Unit::Assertions

    @@obj_count = 0

    def initialize
        super(:author => 'unknown',
              :happened_at => [2006 + @@obj_count, 3, 8],
              :description => 'untitled')
        @expected_times_save_called = 0
        @actual_times_save_called = 0
        
        @@obj_count += 1
    end

    def expect_save
        @expected_times_save_called += 1
    end
    
    def save
        @actual_times_save_called += 1
        super
    end
    
    def verify
        assert_equal @expected_times_save_called, @actual_times_save_called
    end

end
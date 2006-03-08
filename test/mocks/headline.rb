require 'test/unit'

require 'models/headline'

class MockHeadline < Headline

    include Test::Unit::Assertions

    @@obj_count = 0

    def initialize
        super(:author => 'unknown',
              :event_date => DateTime.new(2006 + @@obj_count, 3, 8),
              :title => 'untitled')
        @expected_times_save_called = 0
        @actual_times_save_called = 0
        
        @@obj_count += 1
    end

    def expect_save
        @expected_times_save_called += 1
    end
    
    def save
        super
        @actual_times_save_called += 1
    end
    
    def verify
        assert_equal @expected_times_save_called, @actual_times_save_called
    end

end
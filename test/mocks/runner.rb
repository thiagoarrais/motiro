require 'test/unit'

#A runner is an abstraction for the underlying platform execution engine
class MockRunner

    include Test::Unit::Assertions

    def run(actual_command)
        @run_called = true
        assert_equal @expected_command, actual_command
    end
    
    def expect_run(command)
        @expected_command = command
    end
    
    def verify
        assert @run_called
    end
    
end
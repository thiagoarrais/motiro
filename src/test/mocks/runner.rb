require 'test/unit'

#A runner is an abstraction for the underlying platform execution engine
class MockRunner

    include Test::Unit::Assertions

    def run(command)
        @actual = command
    end
    
    def expect_run(command)
        @expected = command
    end
    
    def verify
        assert_equal @expected, @actual
    end

end
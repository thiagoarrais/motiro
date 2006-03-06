require 'test/unit'

class MockFileSystem
    
    include Test::Unit::Assertions

    def expect_open(filename, &action)
        @expected = filename
        @action = action
    end
    
    def open(filename)
        @actual = filename
        @action.call
    end
    
    def verify
        assert_equal @expected, @actual
    end
    
end
class MockHeadline

    include Test::Unit::Assertions

    def expect_save
    end
    
    def save
        @save_called = true
    end
    
    def verify
        assert @save_called
    end

end
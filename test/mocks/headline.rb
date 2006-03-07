class MockHeadline

    include Test::Unit::Assertions

    def expect_save(&action)
        @action = action    
    end
    
    def save
        @save_called = true
        action.call
    end
    
    def verify
        assert @save_called
    end

end
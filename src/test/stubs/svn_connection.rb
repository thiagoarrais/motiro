class StubSVNConnection

    attr_reader :log

    def initialize
        @log = ''
    end

    def log_append_line(text)
        @log += text + "\n"
    end
    
    def log_prefix_line(text)
        @log = text + "\n" + @log
    end

end

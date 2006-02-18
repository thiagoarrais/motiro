class StubSVNConnection

    attr_reader :log

    def initialize
        @log = ''
    end

    def log_append_line(text)
        @log += text + "\n"
    end
    
end

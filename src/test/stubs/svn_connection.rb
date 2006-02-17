class StubSVNConnection

    def initialize
        @log = ''
    end

    def log_append_line(text)
        @log += text + '\n'
    end

end

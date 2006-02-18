class Headline

    attr_reader :author, :date, :title

    def initialize(author)
        @author = author
    end

end

class SubversionReporter

    def initialize(connection)
        @connection = connection
    end

    def latest_headline
        return svn_parse_log(@connection.log, 1)
    end
    
private
    
    def svn_parse_log(text, num)
        remain = /^-+\n/.match(text).post_match
        md = /^r\d+\s*\|\s*(\w+)\s*\|/.match(remain)
        author = md[1]
        Headline.new(author)
    end

end

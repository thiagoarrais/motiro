require 'date'

class Headline

    attr_reader :author, :date, :title

    def initialize(author, date, title)
        @author, @date, @title = author, date, title
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
        md = /^r\d+\s*\|\s*(\w+)\s*\|\s(\d+)-(\d+)-(\d+)\s+(\d+):(\d+):(\d+)[^\n]*\n/.match(remain)
        remain = md.post_match
        author = md[1]
        year, month, day, hour, min, sec = md[2..7].collect do |s| s.to_i end
        revDate = DateTime.new(year, month, day, hour, min, sec)
        md = /^[^\n]*\n([^\r\n]*)/.match(remain)
        title = md[1]
        Headline.new(author, revDate, title)
    end

end

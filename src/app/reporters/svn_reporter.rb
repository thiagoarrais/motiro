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
        return latest_headlines(1).first
    end
    
    def latest_headlines(num)
        remain = @connection.log
        hls = Array.new
        num.times do
            hl, remain = svn_parse_entry(remain)
            hls.push hl
        end
        return hls
    end
    
private
    
    def svn_parse_entry(text)
        remain = /^-+\n/.match(text).post_match
        md = /^r\d+\s*\|\s*(\w+)\s*\|\s(\d+)-(\d+)-(\d+)\s+(\d+):(\d+):(\d+)[^|]*\|\s*(\d+)\s*[^\n]*\n/.match(remain)
        remain = md.post_match
        author = md[1]
        year, month, day, hour, min, sec = md[2..7].collect do |s| s.to_i end
        numlines = md[8].to_i
        revDate = DateTime.new(year, month, day, hour, min, sec)
        md = /^[^\n]*\n([^\r\n]*)\n/.match(remain)
        title = md[1]
        (numlines).times do
            remain = /\n/.match(remain).post_match
        end
        return Headline.new(author, revDate, title), remain
    end

end

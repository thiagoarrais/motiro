require 'date'
require 'reporters/svn_connection'

require 'models/headline'

require 'core/reporter'

class SubversionReporter < MotiroReporter

    def initialize(connection = SubversionConnection.new)
        super('subversion')
        @connection = connection
    end

    def latest_headline
        return latest_headlines.first
    end
    
    def latest_headlines
        remain = @connection.log
        hls = Array.new

        hl = 0
        until hl.nil? do
            hl, remain = svn_parse_entry(remain)
            hls.push hl unless hl.nil?
        end
        return hls
    end
    
private
    
    def svn_parse_entry(text)
        begin
            remain = /^-+\n/.match(text).post_match
            md = /^r\d+\s*\|\s*(\w+)\s*\|\s(\d+)-(\d+)-(\d+)\s+(\d+):(\d+):(\d+)[^|]*\|\s*(\d+)\s*[^\n]*\n/.match(remain)
            remain = md.post_match
            author = md[1]
            date_components = md[2..7].collect do |s| s.to_i end
            numlines = md[8].to_i
            md = /^[^\n]*\n([^\r\n]*)\n/.match(remain)
            title = md[1]
            (numlines).times do
                remain = /\n/.match(remain).post_match
            end
            return Headline.new(:author => author,
                                :event_date => date_components,
                                :title => title), remain
        rescue
            return nil
        end
    end

end

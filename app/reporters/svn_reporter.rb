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
            unless hl.nil?
                hl.reported_by = self.name
                hls.push hl
            end
        end
        return hls
    end
    
    def article_for(rid)
        revision_id = rid.match(/^r(.+)/)[1]
        
        output = @connection.log(revision_id)
        
        result_headline, remain = svn_parse_entry(output)

        return result_headline.article
    end
    
private
    
    def svn_parse_entry(text)
        begin
            result = Headline.new
            
            result, remain = consume_dashes(result, text)
            result, remain = parse_header(result, remain)
            result, remain = parse_changed_resources(result, remain)
            result, remain = parse_description(result, remain)

            return result, remain
        rescue
            return nil
        end
    end
    
    def consume_dashes(theHeadline, text)
        remain = /^-+\n/.match(text).post_match
        return theHeadline, remain
    end
    
    def parse_header(theHeadline, text)
        md = text.match /^(r\d+)\s*\|\s*(\w+)\s*\|\s(\d+)-(\d+)-(\d+)\s+(\d+):(\d+):(\d+)[^|]*\|\s*(\d+)\s*[^\n]*\n/
        remain = md.post_match
        
        theHeadline.rid = md[1]
        theHeadline.author = md[2]
        theHeadline.happened_at = md[3..8].collect do |s| s.to_i end
        
        return theHeadline, remain
    end
    
    def parse_changed_resources(theHeadline, text)
        remain = text
        
        changes = theHeadline.article.changes

        # skip the first line with the title 'Changed resources' (or something
        # like this)
        remain = remain.match(/\n/).post_match
        
        md = remain.match(/^\n/)
        resources = md.pre_match
        remain = md.post_match
    
        while('' != resources) do
            md = resources.match(/\n/)
            resources = md.post_match
            
            summary = md.pre_match
            changes.push(Change.new(:summary => summary))
        end

        return theHeadline, remain
    end
    
    def parse_description(theHeadline, text)
        md = /^([^\r\n]*)\n/.match(text)
        theHeadline.title = md[1]
        
        md = /\n-+\n/.match(text)
        theHeadline.article.description = md.pre_match
        
        remain = md[0] + md.post_match

        return theHeadline, remain
    end
    
    # consumes lines until a line matching the given regexp is found
    def consume_until(regexp, text)
        theRegexp = Regexp.new("^#{regexp}\n")
        remain = text
        
        while(!remain.match(theRegexp)) do
            remain = remain.match(/\n/.post_match)
        end
        
        return remain
    end
    
end

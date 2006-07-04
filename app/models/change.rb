require 'erb'

class Change < ActiveRecord::Base

    include ERB::Util

    def to_s
        return summary
    end
    
    def render_summary
        if (has_diff?)
            return "<a href='\##{ref}' onClick=\"showOnly('#{ref}')\">#{html_escape(summary)}</a>"
        else
            return summary
        end
    end

    def render_diff
        if (has_diff?)
            return "<div id='#{ref}' class='diff-window'>" +
                     "<center>" +
                     "<a name='#{ref}' />" +
                     "<h2>#{'Changes to %s' / resource_name}</h2>\n" +
                     render_diff_table +
                     "</center>" +
                   "</div>"
        else
            return ''
        end
    end
    
    def render_diff_table
        @differ ||= DiffTableBuilder.new
        diff.split("\n").each do |line|
            c = line[0,1]
            line_text = line[1, line.length - 1]

            if '+' == c then
                @differ.push_addition line_text
            elsif '-' == c then
                @differ.push_deletion line_text
            elsif ' ' == c then
                @differ.push_unchanged line_text
            elsif '@' == c then
                md = line_text.match(/-(\d+)[^\+]*\+(\d+)/)
                @differ.start_line(md[1].to_i, md[2].to_i)
            end
        end
        
        return @differ.render_diff_table
    end
    
    def qualified_resource_name
        return summary.match(/\w ([^\s]+)/)[1]
    end

    def resource_name
        return qualified_resource_name.split('/').last
    end
    
    def filled?
        return !self.resource_kind.nil? &&
                ('dir' == self.resource_kind || !self.diff.nil?)
    end
    
    def use_differ(differ)
        @differ = differ
    end
    
private

    def has_diff?
        return ! (diff.nil? or diff.empty?)
    end

    def ref
        return "change" + summary.hash.to_s
    end
    
end

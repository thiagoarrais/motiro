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
                     "<a name='#{ref}' />" +
                     "<h2>Alterações em #{resource_name}</h2>" +
                     "<pre>\n#{html_escape(diff)}\n</pre>" +
                   "</div>"
        else
            return ''
        end
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
    
private

    def has_diff?
        return ! (diff.nil? or diff.empty?)
    end

    def ref
        return "change" + summary.hash.to_s
    end
    
end

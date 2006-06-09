require 'wiki_ast'

# The root for the wiki abstract syntax tree
class WikiUnit

    def initialize
        @paragraphs = []
    end
    
    def <<(paragraph)
        @paragraphs.push(paragraph)
    end
    
    def paragraphs
        @paragraphs.clone
    end
    
    def render
        result = "<div>\n"
        @paragraphs.each do |p|
            result += "<p>\n"
            result += p.render
            result += "</p>\n"
        end
        result += "</div>"
    end

end
require 'wiki_ast'

# The root for the wiki abstract syntax tree
class WikiUnit

    def initialize
        @paragraphs = {}
    end
    
    def push(paragraph, language=:def_lang)
        @paragraphs[language] ||= []
        @paragraphs[language].push(paragraph)
    end
    
    def paragraphs(language=:def_lang)
        @paragraphs[language].clone
    end
    
    def render(locale=nil)
        result = "<div>\n"
        if locale.nil? then
          paras = paragraphs
        else
          paras = paragraphs(locale)
        end
        
        paras.each do |p|
            result += "<p>\n"
            result += p.render
            result += "</p>\n"
        end
        result += "</div>"
    end

end
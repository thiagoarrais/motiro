require 'wiki_ast'

# Parses wiki-language text into an abstract syntax tree
class WikiParser
    
    def parse(text)
        unit = WikiUnit.new
        text.split(/\r?\n\r?\n/).each do |p|
            unit << parse_paragraph(p)
        end
        return unit
    end
    
    def parse_paragraph(text)
        if (text.strip.match(/\A= (.+) =\z/)) then
            return TitleParagraph.new($1)
        else
            return RawParagraph.new(text)
        end
    end
    
end
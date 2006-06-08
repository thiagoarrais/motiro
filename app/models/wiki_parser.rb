require 'wiki_ast'

# Parses wiki-language text into an abstract syntax tree
class WikiParser
    
    def parse(text)
        unit = WikiUnit.new
        parse_languages(unit, text)
        return unit
    end
    
    def parse_paragraph(text)
        if (text.strip.match(/\A= (.+) =\z/)) then
            return TitleParagraph.new($1)
        else
            return RawParagraph.new(text)
        end
    end
    
private

    def parse_languages(collector, text)
        lang_break = /^--- (\S+) ----*\s*$/
        curr_lang = :def_lang
        remain = text
        while(md = remain.match(lang_break)) do
            parse_paragraphs(collector, curr_lang, md.pre_match)
            remain = md.post_match
            curr_lang = md[1]
        end

        parse_paragraphs(collector, curr_lang, remain)
    end
    
    def parse_paragraphs(collector, language, text)
        text.split(/\r?\n\r?\n/).each do |p|
            if :def_lang == language then
                collector.push(parse_paragraph(p))
            else
                collector.push(parse_paragraph(p), language)
            end
        end
    end
    
end
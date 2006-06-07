class Paragraph
    attr_reader :text
    
    
    def render
        render_links(do_render)
    end
    
protected

    def initialize(text)
        @text = text
    end

private

    def render_links(text)
        md = text.match(/\[([^ ]+) ([^\]]+)\]/)
        if md.nil? then
            return text
        else
            address = md[1]
            reftext = md[2]
            return md.pre_match +
                   "<a href='#{address}'>#{reftext}</a>" +
                   render_links(md.post_match)
        end
    end
    
end

class TitleParagraph < Paragraph

    def do_render
        "<h1>#{text}</h1>"
    end

end

class RawParagraph < Paragraph

    def do_render
        text
    end

end
class Paragraph
    attr_reader :text
    
    def initialize(text)
        @text = text
    end
end

class TitleParagraph < Paragraph

    def render
        "<h1>#{text}</h1>"
    end

end

class RawParagraph < Paragraph

    def render
        text
    end

end
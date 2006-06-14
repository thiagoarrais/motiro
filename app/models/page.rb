class Page < ActiveRecord::Base

    def render_html(locale_code=nil)
        translator = Translator.for(locale_code)
        unit = my_parser.parse(translator.localize(text))
        unit.render
    end
    
    def use_parser(parser)
        @parser = parser
    end

private

    def my_parser
        @parser ||= WikiParser.new
    end
    
end

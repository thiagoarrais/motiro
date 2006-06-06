class Page < ActiveRecord::Base

    def render_html
        unit = my_parser.parse(text)
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

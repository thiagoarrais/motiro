class Page < ActiveRecord::Base

    def render_html(locale=nil)
        unit = my_parser.parse(text)
        if locale.nil? then
          unit.render
        else
          unit.render(locale)
        end
    end
    
    def use_parser(parser)
        @parser = parser
    end

private

    def my_parser
        @parser ||= WikiParser.new
    end
    
end

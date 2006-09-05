class Page < ActiveRecord::Base

  belongs_to :original_author, :class_name => 'User',
                               :foreign_key => 'original_author_id'
  
  def render_html(locale_code=nil)
    translator = Translator.for(locale_code)
    unit = my_parser.parse(translator.localize(text))
    unit.render
  end
  
  def use_parser(parser)
    @parser = parser
  end
  
  def is_open_to_all?
    0 == editors.strip.size
  end
  
private
  
  def my_parser
    @parser ||= WikiParser.new
  end
  
end

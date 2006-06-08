require File.dirname(__FILE__) + '/../test_helper'
require 'wiki_ast'

class WikiParserTest < Test::Unit::TestCase

  def test_breaks_paragraphs_on_linebreak
    unit = WikiParser.new.parse("= Motiro =\n\nThis is project Motiro")
    paragraphs = unit.paragraphs
    assert_equal 2, paragraphs.size
  end
  
  def test_breaks_paragraphs_on_return_feed_plus_linebreak
    unit = WikiParser.new.parse("= Motiro =\r\n\r\nThis is project Motiro")
    paragraphs = unit.paragraphs
    assert_equal 2, paragraphs.size
  end

  # Top level title paragraphs have the following format:
  # 
  # level1_title : '= ' text ' =' $
  # 
  # whitespace is not significative before and after the equals signs
  def test_parses_top_level_title
     paragraph = WikiParser.new.parse_paragraph('= Motiro =')
     assert_kind_of TitleParagraph, paragraph
     assert_equal 'Motiro', paragraph.text
  end
  
  def test_parses_raw_paragraph
     paragraph = WikiParser.new.parse_paragraph('This is project Motiro')
     assert_kind_of RawParagraph, paragraph
     assert_equal 'This is project Motiro', paragraph.text
  end
  
  # Multiple languages can be specified for a page. Languages are identified
  # by a line starting with three dashes, followed by a language/locale string 
  # followed by three or more dashes.
  # 
  # lang_separator: '--- ' locale ' ---' ('-')*
  def test_detects_language_breaks
    unit = WikiParser.new.parse("= Motiro =\n\nEste é o projeto Motiro\n\n" +
                                "--- en ---------\n" +
                                "= Motiro =\n\nThis is project Motiro")
    
    def_paras = unit.paragraphs
    assert_equal 2, def_paras.size
    
    assert_equal 'Este é o projeto Motiro', def_paras[1].text
    
    en_paras = unit.paragraphs('en')
    assert_equal 2, en_paras.size

    assert_equal 'This is project Motiro', en_paras[1].text
  end

end

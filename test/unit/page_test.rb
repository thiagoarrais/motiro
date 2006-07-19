require File.dirname(__FILE__) + '/../test_helper'

class PageTest < Test::Unit::TestCase
  fixtures :pages

  def test_renders_title
    page = Page.new
    page.text = '= Motiro ='
    expected_text = "<div>\n" +
                    "<p>\n" +
                    "<h1>Motiro</h1>" +
                    "</p>\n" +
                    "</div>"
    assert_equal expected_text, page.render_html
  end
  
  def test_renders_multiple_languages
    page = Page.new
    page.text = "Bem-vindo ao Motiro\n\n" +
                "--- en ---\n" +
                "Welcome to Motiro"
    assert_equal "<div>\n<p>\nBem-vindo ao Motiro</p>\n</div>", page.render_html
    assert_equal "<div>\n<p>\nWelcome to Motiro</p>\n</div>",
                 page.render_html('en')
  end

end

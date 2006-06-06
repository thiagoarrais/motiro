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

end

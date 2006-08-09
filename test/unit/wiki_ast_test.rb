require 'wiki_ast'

class WikiAstTest < Test::Unit::TestCase

    def test_render_links
        assert_equal "<p><a href='http://nowhere.com'>Nowhere</a></p>\n",
                     RawParagraph.new('[http://nowhere.com Nowhere]').render
    end

end
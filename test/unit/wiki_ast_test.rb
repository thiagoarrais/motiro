require 'wiki_ast'

class WikiAstTest < Test::Unit::TestCase

    def test_render_links
        assert_equal "<a href='http://nowhere.com'>Nowhere</a>",
                     RawParagraph.new('[http://nowhere.com Nowhere]').render
    end

end
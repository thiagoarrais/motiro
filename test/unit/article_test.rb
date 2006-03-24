require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < Test::Unit::TestCase

    fixtures :articles, :changes

    def test_summarizes_all_changes
        svn_demo_article = articles('svn_demo_article')
        fst_change = changes('svn_demo_add_branches_change')
        snd_change = changes('svn_demo_add_tags_change')
        trd_change = changes('svn_demo_add_trunk_change')
        
        assert_equal fst_change.summary + "\n" +
                     snd_change.summary + "\n" +
                     trd_change.summary, svn_demo_article.summary
        
    end

    
end

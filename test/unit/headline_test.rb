require File.dirname(__FILE__) + '/../test_helper'

require 'rubygems'

require 'flexmock'

# A kind of headline that doesn't have real save method, but a
# fake one that only records the number of times the method got called
class FakeSaveHeadline < Headline

    def initialize(params)
        super(params)
    end

    def times_save_called
        @times_save_called || 0
    end

    def save
        @times_save_called = (@save_times_called || 0) + 1
    end
    
end

class HeadlineTest < Test::Unit::TestCase
    fixtures :headlines, :articles, :changes

    def test_create
        headline = Headline.find(1)
        
        assert_equal 'raulseixas', headline.author
        assert_equal 'gita', headline.title
        assert_equal Time.local(2005, 1, 1), headline.happened_at
    end

    def test_latest_one
        hls = Headline.latest 1
        hl = hls.first
    
        assert_equal 'o dia em que a terra parou', hl.title
    end
    
    def test_cached
       gita_headline = headlines('gita')
       headline = Headline.new(:author => gita_headline.author,
                               :title => gita_headline.title,
                               :happened_at => [2005, 1, 1])
                               
       assert headline.cached?
    end
    
    def test_not_cached
       headline = Headline.new(:author => 'chicobuarque',
                               :title => 'a banda',
                               :happened_at => [1983, 1, 1])
                               
      assert ! headline.cached?
    end
    
    def test_record_time
       headline = Headline.new(:author => 'thiagoarrais',
                               :title => 'fiz besteira',
                               :happened_at => [1983, 1, 1, 00, 15, 12])
                               
       headline.save
       
       headline = Headline.find(:first,
                                :conditions => "author = 'thiagoarrais' and title = 'fiz besteira'")
                                
       assert_equal Time.local(1983, 1, 1, 00, 15, 12), headline.happened_at
    end
    
    def test_cache_with_date_time
       aHeadline = Headline.new(:author => 'thiagoarrais',
                                :title => 'fiz besteira',
                                :happened_at => [1983, 1, 1, 00, 15, 12])
       aHeadline.save
       
       assert aHeadline.cached?
    end
    
    

    def test_cache_new
        aHeadline = FakeSaveHeadline.new(:author => 'thiagoarrais',
                                        :title => 'this is a new headline',
                                        :happened_at => [1983, 1, 1, 00, 15, 12])
                               
        aHeadline.cache
        
        assert(1, aHeadline.times_save_called)
    end
    
    def test_cache_already_recorded
        aHeadline = FakeSaveHeadline.new(:author => 'thiagoarrais',
                                         :title => 'we will try to cache this headline twice',
                                         :happened_at => [1983, 8, 8, 07, 15, 12])
        
        aHeadline.cache
        aHeadline.cache
        
        assert(1, aHeadline.times_save_called)
    end
    
    def test_retrieves_corresponding_article
        svn_demo_headline = headlines('svn_demo_headline')
        svn_demo_article = articles('svn_demo_article')
        aHeadline = Headline.find(svn_demo_headline.id)
        
        article = aHeadline.article
        assert_equal svn_demo_article.description, article.description
    end
    
    def test_saving_also_saves_article_inside
        aHeadline = Headline.new(:author => 'thiagoarrais',
                                 :title => 'this is the headline title',
                                 :reported_by => 'subversion',
                                 :happened_at => [1983, 1, 1, 02, 15, 12],
                                 :rid => 'r47')
                                
        full_comment = "this is the headline title\n" +
                       "\n"  +
                       "this is the full comment"

        aHeadline.article = Article.new(:description => full_comment)
       
        aHeadline.save
       
        article = Article.find(:first,
                              :conditions => ["description = ?",
                                              full_comment]) 
        assert_not_nil article
    end
    
    def test_search_by_reporter_name_and_rid
        svn_demo_headline = headlines('svn_demo_headline')
        aHeadline = Headline.find_with_reporter_and_rid(svn_demo_headline.reported_by,
                                                        svn_demo_headline.rid)
        
        assert_not_nil aHeadline
        assert_equal svn_demo_headline, aHeadline
    end
    
end

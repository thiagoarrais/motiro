require File.dirname(__FILE__) + '/../test_helper'

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
    fixtures :headlines

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
       headline = Headline.new(:author => 'raulseixas',
                               :title => 'gita',
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
    
end

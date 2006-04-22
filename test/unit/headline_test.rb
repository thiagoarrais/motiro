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
    fixtures :headlines, :changes

    def test_create
        headline = Headline.find(1)
        
        assert_equal 'raulseixas', headline.author
        assert_equal 'gita', headline.title
        assert_equal Time.local(2005, 1, 1), headline.happened_at
    end

    def test_latest_one
        hls = Headline.latest(1, 'subversion')
        hl = hls.first
    
        assert_equal 'o dia em que a terra parou', hl.title
    end
    
    def test_cached
       svn_demo_headline = headlines('svn_demo_headline')
       headline = Headline.new(:author => svn_demo_headline.author,
                               :title => svn_demo_headline.title,
                               :happened_at => [2006, 03, 23, 11, 10, 04])
                               
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
    
    def test_search_by_reporter_name_and_rid
        svn_demo_headline = headlines('svn_demo_headline')
        aHeadline = Headline.find_with_reporter_and_rid(svn_demo_headline.reported_by,
                                                        svn_demo_headline.rid)
        
        assert_not_nil aHeadline
        assert_equal svn_demo_headline, aHeadline
    end
    
    def test_not_filled
        fst_change, snd_change = FlexMock.new, FlexMock.new
        
        fst_change.should_receive(:filled?).
            returns(true)
        snd_change.should_receive(:filled?).
            returns(false)
            
        a_headline = create_headline_with_changes(fst_change, snd_change)
        
        assert !a_headline.filled?
        
        [fst_change, snd_change].each do |m|
            m.mock_verify
        end
    end
    
    def test_filled
        change = FlexMock.new
        
        change.should_receive(:filled?).
            returns(true)
            
        a_headline = create_headline_with_changes(change, change)
        
        assert a_headline.filled?
        
        change.mock_verify
    end
    
    def test_recaches_failed
        filled_change = Change.new(:summary => 'A /trunk/app/models/headline.rb',
                                   :resource_kind => 'file',
                                   :diff => '+change')
        failed_change = Change.new(:summary => 'A /trunk/test/unit/headline_test.rb',
                                   :resource_kind => 'file',
                                   :diff => nil)

        a_headline = create_headline_with_changes(filled_change, failed_change)

        a_headline.cache
        
        failed_change.diff = '+def test_headline; end'
        
        a_headline = create_headline_with_changes(filled_change, failed_change)

        assert !a_headline.cached?
        
        a_headline.cache
        
        assert a_headline.cached?
        
        hls = Headline.find(:all, :conditions => ["title = ?", a_headline.title])     
        
        assert_equal 1, hls.size
    end

private

    def create_headline_with_changes(*changes)
        a_headline = Headline.new(:author => 'thiagoarrais',
                                  :title => 'this is the headline title',
                                  :reported_by => 'subversion',
                                  :happened_at => [1983, 1, 1, 02, 15, 12],
                                  :rid => 'r47')
                                  
        changes.reverse.each do |c|
            a_headline.changes.unshift(c)
        end
        
        return a_headline
    end
    
end

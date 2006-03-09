require File.dirname(__FILE__) + '/../test_helper'

class HeadlineTest < Test::Unit::TestCase
    fixtures :headlines

    def test_create
        headline = Headline.find(1)
        
        assert_equal 'raulseixas', headline.author
        assert_equal 'gita', headline.title
        assert_equal Time.local(2005, 1, 1), headline.event_date
    end

    def test_latest_one
        hls = Headline.latest 1
        hl = hls.first
    
        assert_equal 'o dia em que a terra parou', hl.title
    end
    
    def test_cached
       headline = Headline.new(:author => 'raulseixas',
                               :title => 'gita',
                               :event_date => Time.local(2005, 1, 1))
                               
       assert headline.cached?
    end
    
    def test_not_cached
       headline = Headline.new(:author => 'chicobuarque',
                               :title => 'a banda',
                               :event_date => Time.local(1983, 1, 1))
                               
      assert ! headline.cached?
    end
    
    def test_record_time
       headline = Headline.new(:author => 'thiagoarrais',
                               :title => 'fiz besteira',
                               :event_date => Time.local(1983, 1, 1, 00, 15, 12))
                               
       headline.save
       
       headline = Headline.find(:first,
                                :conditions => "author = 'thiagoarrais' and title = 'fiz besteira'")
                                
       assert_equal Time.local(1983, 1, 1, 00, 15, 12), headline.event_date
    end
    
end

require File.dirname(__FILE__) + '/../test_helper'

class HeadlineTest < Test::Unit::TestCase
    fixtures :headlines

    def test_create
        headline = Headline.find(1)
        
        assert_equal 'raulseixas', headline.author
        assert_equal 'gita', headline.title
        assert_equal DateTime.new(2005, 1, 1), headline.event_date
    end

    def test_latest_one
        hls = Headline.latest 1
        hl = hls.first
    
        assert_equal 'o dia em que a terra parou', hl.title
    end
  
end

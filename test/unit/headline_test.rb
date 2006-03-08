require File.dirname(__FILE__) + '/../test_helper'

class HeadlineTest < Test::Unit::TestCase
  fixtures :headlines

  def test_latest
    hls = Headline.latest 1
    hl = hls.first
    
    assert_equal 'gita', hl.title
  end
  
end

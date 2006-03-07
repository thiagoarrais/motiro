require File.dirname(__FILE__) + '/../test_helper'

class HeadlineTest < Test::Unit::TestCase
  fixtures :headlines

  # Replace this with your real tests.
  def test_latest
    hls = Headline.latest 1
    hl = hls.first
    
    assert_equal 'gita', hl.title
  end
end

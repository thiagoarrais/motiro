require File.dirname(__FILE__) + '/../test_helper'

class HeadlineTest < Test::Unit::TestCase
  fixtures :headlines

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Headline, headlines(:first)
  end
end

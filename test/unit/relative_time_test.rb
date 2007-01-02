require File.dirname(__FILE__) + '/../test_helper'

class RelativeTimeTest < Test::Unit::TestCase 

  def midnight_17_july_2006; Time.local(2006, 07, 17, 00, 00, 00); end
  
  def setup
    Locale.set('en')
  end
  
  def test_time_ago_in_weeks
    t = Time.local(2006, 07, 1, 15, 32, 27)
    assert_equal '2 weeks ago', t.relative_to_now(midnight_17_july_2006)
  end

  def test_time_ago_in_days
    t = Time.local(2006, 07, 15, 00, 00, 00)
    assert_equal '2 days ago', t.relative_to_now(midnight_17_july_2006)
  end
  
  def test_exactly_one_day_ago
    t = Time.local(2006, 07, 16, 00, 00, 00)
    assert_equal 'Yesterday', t.relative_to_now(midnight_17_july_2006)
  end
  
  def test_time_ago_in_hours
    t = Time.local(2006, 07, 16, 22, 50, 00)
    assert_equal '1 hour ago', t.relative_to_now(midnight_17_july_2006)
  end

  def test_less_than_one_minute_ago
    t = Time.local(2006, 07, 16, 23, 59, 43)
    assert_equal 'Less than one minute ago', t.relative_to_now(midnight_17_july_2006)
  end
  
  def test_time_ago_in_months
    t = Time.local(2006, 03, 16, 23, 59, 43)
    assert_equal '4 months ago', t.relative_to_now(midnight_17_july_2006)
  end
  
  def test_time_ago_in_years
    t = Time.local(2003, 03, 16, 23, 59, 43)
    assert_equal '3 years ago', t.relative_to_now(midnight_17_july_2006)
  end
  
  def test_time_from_now
    t = Time.local(2006, 07, 20, 00, 00, 00)
    assert_equal '3 days from now', t.relative_to_now(midnight_17_july_2006)
  end
  
  def test_one_day_from_now
    t = Time.local(2006, 07, 18, 12, 00, 00)
    assert_equal 'Tomorrow', t.relative_to_now(midnight_17_july_2006)
  end

end
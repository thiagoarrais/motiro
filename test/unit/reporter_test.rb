#  Motiro - A project tracking tool
#  Copyright (C) 2006-2007  Thiago Arrais
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

require File.dirname(__FILE__) + '/../test_helper'

class MyDefaultReporter < MotiroReporter; end

class MyCustomReporter < MotiroReporter
  title 'This is the Custom reporter'
end

class TwoButtonReporter < MotiroReporter
  add button[:add_events]
end

class NonCachingReporter < MotiroReporter
  caching :off
end

class MotiroReporterTest < Test::Unit::TestCase
  
  def test_default_title
    default_reporter = MyDefaultReporter.new
    
    assert_equal 'Latest news from My default',
    default_reporter.channel_title
  end
  
  def test_custom_title
    custom_reporter = MyCustomReporter.new
    
    assert_equal 'This is the Custom reporter',
    custom_reporter.channel_title
  end
  
  def test_guesses_reporter_name
    default_reporter = MyDefaultReporter.new
    custom_reporter = MyCustomReporter.new
    
    assert_equal 'my_default', default_reporter.name
    assert_equal 'my_custom', custom_reporter.name
  end
  
  def test_one_button_reporter
    assert_equal [ MotiroReporter.button[:older] ], MyCustomReporter.new.buttons
  end
  
  def test_two_button_reporter
    assert_equal [ MotiroReporter.button[:older],
                   MotiroReporter.button[:add_events] ],
                 TwoButtonReporter.new.buttons
  end
  
  def test_switch_headline_caching
    assert ! NonCachingReporter.new.cache?
    assert MyDefaultReporter.new.cache?
  end
  
end
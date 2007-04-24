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

  NEW_EVENT_BUTTON = 
    "if current_user.nil?; " +
    "  content_tag('span', 'Add'.t, :class => 'disabled'); " +
    "else; " +
    "  link_to( 'Add'.t, :controller => 'wiki', " + 
                        ":action => 'new', :kind => 'event'); " +
    "end;"

  NEW_FEATURE_BUTTON = 
    "if current_user.nil?; " +
    "  content_tag('span', 'Add'.t, :class => 'disabled'); " +
    "else; " +
    "  link_to( 'Add'.t, :controller => 'wiki', " + 
                        ":action => 'new', :kind => 'feature'); " +
    "end;"

class WikiReporterTest < Test::Unit::TestCase

  fixtures :users
  
  def button; MotiroReporter.button; end

  def test_title
    assert_equal 'Recently changed suggestions', FeaturesReporter.new.channel_title
    assert_equal 'Scheduled events', EventsReporter.new.channel_title
  end
  
  def test_button
    assert_equal [button[:older], NEW_FEATURE_BUTTON], FeaturesReporter.new.buttons
    assert_equal [button[:older], NEW_EVENT_BUTTON], EventsReporter.new.buttons
  end
  
  def test_kind
    FlexMock.use do |page_provider|
      page_provider.should_receive(:find).
        once.and_return([]).
        with(:all, :conditions => "kind = 'feature'",
                   :order => 'modified_at DESC')
      page_provider.should_receive(:find).
        once.and_return([]).
        with(:all, :conditions => "kind = 'event'",
                   :order => 'happens_at DESC')
      
      FeaturesReporter.new(:page_provider => page_provider).headlines
      EventsReporter.new(:page_provider => page_provider).headlines
    end
  end
  
  def test_features_reporter_uses_modification_time
    FlexMock.use do |page_provider|
      mod_time = Time.local(2007, 1, 19, 15, 23, 8)
      page_provider.should_receive(:find).
        zero_or_more_times.
        and_return([Page.new(:name => 'FeaturePage').revise(bob, mod_time, 
                             :title => 'Feature page')])
      hl = FeaturesReporter.new(:page_provider => page_provider).headlines[0]
      assert_equal mod_time, hl.happened_at
    end
  end
  
  def test_events_reporter_uses_planned_date
    FlexMock.use do |page_provider|
      planned_date = Date.civil(2007, 1, 19)
      page_provider.should_receive(:find).
        zero_or_more_times.
        and_return([Page.new(:name => 'EventPage').revise(bob, now,
                             :happens_at => planned_date,
                             :title => 'Event page')])
      hl = EventsReporter.new(:page_provider => page_provider).headlines[0]
      assert_equal planned_date.to_t, hl.happened_at
    end
  end
  
  def test_respond_to_latest_headlines
    FlexMock.use do |page_provider|
      page_provider.should_receive(:find).zero_or_more_times.and_return([])

      assert_equal 0, EventsReporter.new(:page_provider => page_provider).
                        latest_headlines('something').size
    end
  end

end

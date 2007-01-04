#  Motiro - A project tracking tool
#  Copyright (C) 2006  Thiago Arrais
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

require 'stub_hash'
require 'stubs/svn_settings'
require 'mocks/headline'

require 'core/cache_reporter'

class CacheReporterTest < Test::Unit::TestCase
  
  def test_latest_headlines
    FlexMock.use do |mock_headline_class| 
      settings = StubConnectionSettingsProvider.new(:package_size => 6)
      underlying_reporter = {:name => 'mail_list' }
      
      mock_headline_class.should_receive(:latest).
        with(6, 'mail_list').
        once
      
      reporter = CacheReporter.new(underlying_reporter, settings, mock_headline_class)
      reporter.latest_headlines
    end
  end
  
  def test_retrieve_all_headlines
    FlexMock.use do |mock_headline_class| 
      settings = StubConnectionSettingsProvider.new(:package_size => 6)
      underlying_reporter = {:name => 'mail_list'}
      
      mock_headline_class.should_receive(:find_all).
        with(['reported_by = ?', 'mail_list'], 'happened_at DESC').
        once

      reporter = CacheReporter.new(underlying_reporter, settings, mock_headline_class)
      reporter.headlines
    end
  end

  def test_headline
    FlexMock.use do |mock_headline_class| 
      settings = StubConnectionSettingsProvider.new(:package_size => 6)
      underlying_reporter = {:name => 'mail_list' }
      
      mock_headline_class.should_receive(:find_with_reporter_and_rid).
        with('mail_list', 'm18').
        returns(MockHeadline.new).
        once
      
      reporter = CacheReporter.new(underlying_reporter, settings, mock_headline_class)
      reporter.headline('m18')
    end
  end
  
  def test_mimics_underlying_reporter_name
    svn_cache = CacheReporter.new({ :name => 'svn'})
    darcs_cache = CacheReporter.new({ :name => 'darcs'})
    
    assert_equal 'svn', svn_cache.name
    assert_equal 'darcs', darcs_cache.name
  end
  
  def test_mimics_underlying_reporter_title
    title = 'My reporter title'
    r = CacheReporter.new(:channel_title => title)
    
    assert_equal title, r.channel_title 
  end
  
end

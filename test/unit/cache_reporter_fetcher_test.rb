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

require 'core/cache_reporter_fetcher'

class CacheReporterFetcherTest < Test::Unit::TestCase

  def test_fetched_reporters_are_cache_reporters
    underlying_reporter = { :cache? => true, :name => 'mock_reporter'}
    underlying_fetcher = {:active_reporters => [underlying_reporter] }

    reporters = CacheReporterFetcher.new(underlying_fetcher).active_reporters

    assert_equal 1, reporters.size
    assert_equal CacheReporter, reporters.first.class
    assert_equal 'mock_reporter', reporters.first.name
  end
  
  def test_bypass_caching_for_reporters_who_dont_want_caching
    underlying_reporter = { :cache? => false, :name => 'mock_reporter'}
    underlying_fetcher = {:active_reporters => [underlying_reporter] }
      
    reporters = CacheReporterFetcher.new(underlying_fetcher).active_reporters
      
    assert_equal underlying_reporter, reporters.first
  end
  
end

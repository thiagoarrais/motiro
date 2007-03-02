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

require 'core/reporter_driver'

class ReporterDriverTest < Test::Unit::TestCase
  
  def test_ticks_one_reporter
    FlexMock.use('1', '2') do |fetcher, reporter|
      fetcher.should_receive(:active_reporters).once.returns([reporter])
      reporter.should_receive(:name).once.returns('subversion')
      reporter.should_receive(:latest_headlines).once.returns([])
        
      driver = ReporterDriver.new(fetcher)
      
      driver.tick              
    end
  end
  
  def test_ticks_more_than_one_reporter
    FlexMock.use('1', '2') do |fetcher, reporter|
      fetcher.should_receive(:active_reporters).once.
        returns([reporter, reporter])
      reporter.should_receive(:name).twice.returns('subversion')
      reporter.should_receive(:latest_headlines).twice.returns([])
        
      driver = ReporterDriver.new(fetcher)
      
      driver.tick              
    end
  end

  def test_caches_headlines
    FlexMock.use('1', '2') do |reporter, fetcher|
      headlines = [FlexMock.new, FlexMock.new, FlexMock.new,
                   FlexMock.new, FlexMock.new]
      fetcher.should_receive(:active_reporters).returns([reporter])
      reporter.should_receive(:name).returns('subversion')
      reporter.should_receive(:latest_headlines).returns(headlines)
      headlines.each do |hl|
        hl.should_receive(:cache).once
      end
      
      driver = ReporterDriver.new(fetcher)
      
      driver.tick
      
      headlines.each do |hl|
        hl.mock_verify
      end
    end
  end
  
  def test_askes_for_new_headlines_only
    FlexMock.use('1', '2', '3') do |reporter, fetcher, headline_cache|
      fetcher.should_receive(:active_reporters).returns([reporter])
      reporter.should_receive(:name).returns('subversion')
      headline_cache.should_receive(:latest_filled_headline_rid_for).
        with('subversion').returns('r523')
      reporter.should_receive(:latest_headlines).with('r523').returns([])
      
      ReporterDriver.new(fetcher, headline_cache).tick
    end
  end
  
  # TODO what when there are no headlines yet cached or the ones cached aren't
  #      filled?

end
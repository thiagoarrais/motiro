require File.dirname(__FILE__) + '/../test_helper'

require 'core/reporter_driver'

class ReporterDriverTest < Test::Unit::TestCase
  
  def test_ticks_one_reporter
    FlexMock.use('1', '2') do |fetcher, reporter|
      fetcher.should_receive(:active_reporters).once.
        returns([reporter])
      
      reporter.should_receive(:latest_headlines).once.
        returns([])
        
      driver = ReporterDriver.new(fetcher)
      
      driver.tick              
    end
  end
  
  def test_ticks_more_than_one_reporter
    FlexMock.use('1', '2') do |fetcher, reporter|
      fetcher.should_receive(:active_reporters).once.
        returns([reporter, reporter])
      
      reporter.should_receive(:latest_headlines).twice.
        returns([])
        
      driver = ReporterDriver.new(fetcher)
      
      driver.tick              
    end
  end

  def test_caches_headlines
    FlexMock.use('1', '2') do |reporter, fetcher|
      headlines = [FlexMock.new, FlexMock.new, FlexMock.new,
                   FlexMock.new, FlexMock.new]
      fetcher.should_receive(:active_reporters).
        returns([reporter])
      reporter.should_receive(:latest_headlines).
        returns(headlines)
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

end
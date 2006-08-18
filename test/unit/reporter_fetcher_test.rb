require File.dirname(__FILE__) + '/../test_helper'

require 'core/reporter_fetcher'

class ReporterFetcherTest < Test::Unit::TestCase

  def test_loads_only_active_reporters
    FlexMock.use('1', '2') do |loader, reporter|
      settings = StubConnectionSettingsProvider.new(
                   :active_reporter_ids => ['darcs', 'mail'])
      
      loader.should_receive(:create_reporter).with('darcs').
        returns(reporter).once
      loader.should_receive(:create_reporter).with('mail').
        returns(reporter).once
      
      fetcher = ReporterFetcher.new(settings, loader)

      assert_equal([reporter, reporter], fetcher.active_reporters)
    end
  end
    

end

require File.dirname(__FILE__) + '/../test_helper'

require 'core/reporter_fetcher'

require 'reporters/events_reporter'
require 'reporters/features_reporter'

class ReporterFetcherTest < Test::Unit::TestCase

  def test_loads_only_active_reporters_plus_events_and_features
    FlexMock.use('1', '2') do |loader, reporter|
      settings = StubConnectionSettingsProvider.new(
                   :active_reporter_ids => ['darcs', 'mail'])
      
      loader.should_receive(:create_reporter).with('darcs').
        returns(reporter).once
      loader.should_receive(:create_reporter).with('mail').
        returns(reporter).once
      
      fetcher = ReporterFetcher.new(settings, loader)

      reporters = fetcher.active_reporters
      assert_equal(4, reporters.size)
      assert_equal([reporter, reporter], reporters[0..1])
      assert_equal(FeaturesReporter, reporters[2].class)
      assert_equal(EventsReporter, reporters[3].class)
    end
  end
    

end

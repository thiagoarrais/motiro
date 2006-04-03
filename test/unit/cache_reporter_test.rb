require File.dirname(__FILE__) + '/../test_helper'

require 'stubs/svn_settings'

require 'core/cache_reporter'

class CacheReporterTest < Test::Unit::TestCase

    def test_reads_from_database
        FlexMock.use do |mock_headline_class| 
            settings = StubConnectionSettingsProvider.new(
                           :package_size => 6)
            
            mock_headline_class.should_receive(:latest).
                with(6, 'mail_list').
                once
            
            reporter = CacheReporter.new('mail_list',
                                         settings,
                                         mock_headline_class)
            reporter.latest_headlines
        end
    end

end

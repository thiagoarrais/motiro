require File.dirname(__FILE__) + '/../test_helper'

require 'local_svn'
require 'svn_excerpts'

require 'stubs/svn_settings'

require 'core/chief_editor'
require 'core/reporter_driver'

require 'reporters/subversion_reporter'

class CachingTest < Test::Unit::TestCase

    def setup
        clean_database
        create_fixture_objects
    end

    def test_recaches_failures
        @connection.should_receive(:log).
            with_any_args.
            returns(R6 + "-------------\n")

        diff = '' # simulate connection timeout
        
        @connection.mock_handle(:diff) do
            diff
        end

        @connection.should_receive(:info).
            with('/trunk/src/test/stubs/svn_connection.rb', '6').
            returns(R6C1INFO)

        @connection.should_receive(:info).
            with('/trunk/src/test/unit/headline_test.rb', '6').
            returns(R6C2INFO)

        @driver.tick
        
        headlines = @chief_editor.latest_news_from(@reporter.name)
        changes = headlines.first.changes
        assert_nil changes.first.diff
        
        diff = R6DIFF # connection is back
        
        @driver.tick

        headlines = @chief_editor.latest_news_from(@reporter.name)
        changes = headlines.first.changes
        assert_not_nil changes.first.diff
        assert_equal R6C1DIFF, changes.first.diff
    end
    
    def teardown
        clean_database
    end
    
private

    def clean_database
        Headline.delete_all
    end

    def create_fixture_objects
        @connection = FlexMock.new
        settings = StubConnectionSettingsProvider.new(:update_interval => 12)
        @reporter = SubversionReporter.new(@connection)

        fetcher = FlexMock.new
        fetcher.should_receive(:active_reporters).returns([@reporter])

        @driver = ReporterDriver.new(fetcher)

        @chief_editor = ChiefEditor.new(settings, fetcher)
    end
    
end
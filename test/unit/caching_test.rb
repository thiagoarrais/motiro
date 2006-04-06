require File.dirname(__FILE__) + '/../test_helper'

require 'local_svn'
require 'svn_excerpts'

require 'stubs/svn_settings'

require 'core/chief_editor'

require 'reporters/svn_driver'
require 'reporters/svn_reporter'

class CachingTest < Test::Unit::TestCase

    def setup
        clean_database
        create_fixture_objects
    end

    def test_recaches_failures
        @connection.should_receive(:log).
            with_any_args.
            returns(R6 + "-------------\n")

        @connection.should_receive(:diff).with(6).
            with_any_args.
            returns('') # simulate bad or no output

        @driver.tick
        
        headlines = @chief_editor.latest_news_from(@reporter.name)
        changes = headlines.first.article.changes
        assert_nil changes.first.diff
        
        @connection.should_receive(:diff).with(6).
            with_any_args.
            returns(R6DIFF) # connection is back
        
        headlines = @chief_editor.latest_news_from(@reporter.name)
        changes = headlines.first.article.changes
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
        @driver = SubversionDriver.new(@reporter)

        @chief_editor = ChiefEditor.new(settings)
        @chief_editor.employ(@reporter)
    end
    
end
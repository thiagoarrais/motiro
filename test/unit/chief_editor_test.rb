require File.dirname(__FILE__) + '/../test_helper'

require 'core/chief_editor'

require 'stubs/svn_settings'
require 'mocks/headline'

require 'mocks/svn_reporter'

class Class
    include Test::Unit::Assertions
end

class Headline
    @@old_latest = self.method(:latest)

    def self.old_latest(num)
        @@old_latest.call(num)        
    end
end                

class ChiefEditorTest < Test::Unit::TestCase

    @@log = ''

    def self.append_to_log(txt)
        @@log << txt
    end

    def test_reads_package_size
        settings = StubConnectionSettingsProvider.new(
                       :package_size => 6)

        chief_editor = ChiefEditor.new(settings)

        def Headline.latest(num)
            assert_equal 6, num
            ChiefEditorTest.append_to_log('latest')
            return Array.new.fill(MockHeadline.new, 6)
        end
        
        chief_editor.latest_news_from 'subversion'
        
        assert_equal 'latest', @@log
        
        def Headline.latest(num)
            old_latest(num)
        end
    end
    
    def test_refetches_news_on_every_call_when_in_development_mode
        settings = StubConnectionSettingsProvider.new(
                       :update_interval => 0)
                       
        chief_editor = ChiefEditor.new(settings)
        
        reporter = MockSubversionReporter.new

        chief_editor.employ reporter
        
        reporter.expect_latest_headlines do
            Array.new.fill(MockHeadline.new, 0, 3)
        end
        
        chief_editor.latest_news_from 'subversion'
        
        reporter.verify
    end
    
    def test_does_not_ask_reporter_in_production_mode
        settings = StubConnectionSettingsProvider.new(
                       :update_interval => 6)

        chief_editor = ChiefEditor.new(settings)
        
        reporter = MockSubversionReporter.new

        chief_editor.employ reporter
        
        chief_editor.latest_news_from 'subversion'
        
        reporter.verify
    end
    
    #TODO should signal when the reporter is not registered
end
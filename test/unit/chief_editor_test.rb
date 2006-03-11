require File.dirname(__FILE__) + '/../test_helper'

require 'core/chief_editor'

require 'stubs/svn_settings'
require 'mocks/headline'

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
            return Array.new.fill MockHeadline.new, 6
        end
        
        chief_editor.latest_news_from 'subversion'
        
        assert_equal 'latest', @@log
        
        def Headline.latest(num)
            old_latest(num)
        end
    end
    
    #TODO should signal when the reporter is not registered
end
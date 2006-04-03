require File.dirname(__FILE__) + '/../test_helper'

require 'stubs/svn_settings'
require 'mocks/headline'

require 'core/cache_reporter'

class CacheReporterTest < Test::Unit::TestCase

    def test_latest_headlines
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
    
    def test_article_for
        FlexMock.use do |mock_headline_class| 
            settings = StubConnectionSettingsProvider.new(
                           :package_size => 6)
            
            mock_headline_class.should_receive(:find_with_reporter_and_rid).
                with('mail_list', 'm18').
                returns(MockHeadline.new).
                once
            
            reporter = CacheReporter.new('mail_list',
                                         settings,
                                         mock_headline_class)
            reporter.article_for('m18')
        end
    end

end

require File.dirname(__FILE__) + '/../test_helper'

require 'test/unit'

require 'mocks/svn_reporter'
require 'mocks/headline'

require 'reporters/svn_driver'

class SubversionDriverTest < Test::Unit::TestCase
    
    def setup
        @reporter = MockSubversionReporter.new
        @driver = SubversionDriver.new(@reporter)
        @headlines = [MockHeadline.new, MockHeadline.new, MockHeadline.new,
                     MockHeadline.new, MockHeadline.new]
        
        # expect save to be called only once for each headline
        @headlines.each do |hl|
            hl.expect_save
        end
        
        @reporter.expect_latest_headlines do
            @headlines
        end
        
    end

    def test_records
        @driver.tick
    end
    
    def test_already_cached_headline
        @reporter.expect_latest_headlines
        
        @driver.tick
        @driver.tick
    end
    
    def teardown
        @reporter.verify

        @headlines.each do |hl|
            hl.verify
        end
    end
    
end
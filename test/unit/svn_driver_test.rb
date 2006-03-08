require File.dirname(__FILE__) + '/../test_helper'

require 'test/unit'

require 'mocks/svn_reporter'
require 'mocks/headline'

require 'reporters/svn_driver'

class SubversionDriverTest < Test::Unit::TestCase
    
    def setup
        @reporter = MockSubversionReporter.new
        @driver = SubversionDriver.new(@reporter)
    end

    def test_records
        
        headlines = Array.new.fill MockHeadline.new, 5
        
        headlines.each do |hl|
            hl.expect_save
        end
        
        @reporter.expect_latest_headlines(5) do
            headlines
        end
        
        @driver.tick
        
        @reporter.verify

        headlines.each do |hl|
            hl.verify
        end
        
    end
    
    def test_already_cached_headline
        
        headlines = [MockHeadline.new, MockHeadline.new, MockHeadline.new,
                     MockHeadline.new, MockHeadline.new]
        
        # expect save to be called only once for each headline
        headlines.each do |hl|
            hl.expect_save
        end
        
        @reporter.expect_latest_headlines(5) do
            headlines
        end
        
        @reporter.expect_latest_headlines(5)
        
        @driver.tick
        @driver.tick
        
        # @reporter.verify

        headlines.each do |hl|
            hl.verify
        end
        
    end
    
end
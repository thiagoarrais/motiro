require File.dirname(__FILE__) + '/../test_helper'

require 'test/unit'

require 'mocks/svn_reporter'
require 'mocks/headline'

require 'reporters/svn_driver'

class SubversionDriverTest < Test::Unit::TestCase
    
    def test_records
        
        reporter = MockSubversionReporter.new
        driver = SubversionDriver.new(reporter)
        headlines = Array.new.fill MockHeadline.new, 5
        
        headlines.each do |hl|
            hl.expect_save
        end
        
        reporter.expect_latest_headlines(5) do
            headlines
        end
        
        driver.tick
        
        reporter.verify

        headlines.each do |hl|
            hl.verify
        end
        
    end
    
    #TODO test already cached headline
    
end
require 'test/unit'

require 'mocks/svn_reporter'
require 'mocks/headline'


class SubversionDriverTest < Test::Unit::TestCase
    
    def test_records
        
        reporter = MockSubversionReporter.new
        driver = SubversionDriver.new
        headlines = Array.new
        headlines.push MockHeadline.new
        headlines.push MockHeadline.new
        
        headlines.each do |hl|
            hl.expect_save
        end
        
        reporter.expect_latest_headlines do
            headlines
        end
        
        driver.tick
        
        headlines.each do |hl|
            hl.verify
        end
        
        reporter.verify

    end
    
end
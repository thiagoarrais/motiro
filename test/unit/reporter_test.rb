require File.dirname(__FILE__) + '/../test_helper'

class MyDefaultTitleReporter < MotiroReporter; end

class MyCustomTitleReporter < MotiroReporter
    title 'This is the Custom reporter'
end

class MotiroReporterTest < Test::Unit::TestCase
    
    def test_default_title
        default_reporter = MyDefaultTitleReporter.new
        
        assert_equal 'Últimas notícias do My default title',
                     default_reporter.channel_title
    end
    
    def test_custom_title
        custom_reporter = MyCustomTitleReporter.new
        
        assert_equal 'This is the Custom reporter',
                     custom_reporter.channel_title
    end
    
    def test_guesses_reporter_name
        default_reporter = MyDefaultTitleReporter.new
        custom_reporter = MyCustomTitleReporter.new
        
        assert_equal 'my_default_title', default_reporter.name
        assert_equal 'my_custom_title', custom_reporter.name
    end
    
end
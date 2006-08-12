require File.dirname(__FILE__) + '/../test_helper'

class MyDefaultReporter < MotiroReporter; end

class MyCustomReporter < MotiroReporter
    title 'This is the Custom reporter'
    use_toolbar 'custom/toolbar'
end

class MotiroReporterTest < Test::Unit::TestCase
    
    def test_default_title
        default_reporter = MyDefaultReporter.new
        
        assert_equal 'Latest news from My default',
                     default_reporter.channel_title
    end
    
    def test_custom_title
        custom_reporter = MyCustomReporter.new
        
        assert_equal 'This is the Custom reporter',
                     custom_reporter.channel_title
    end
    
    def test_guesses_reporter_name
        default_reporter = MyDefaultReporter.new
        custom_reporter = MyCustomReporter.new
        
        assert_equal 'my_default', default_reporter.name
        assert_equal 'my_custom', custom_reporter.name
    end
    
    def test_toolbar
      assert_nil MyDefaultReporter.new.toolbar
      assert_equal 'custom/toolbar', MyCustomReporter.new.toolbar
    end
    
end
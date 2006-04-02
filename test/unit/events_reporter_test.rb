require File.dirname(__FILE__) + '/../test_helper'

require 'reporters/events_reporter'

class EventsReporterTest < Test::Unit::TestCase

    def test_channel_title
        reporter = EventsReporter.new
        
        assert_equal 'Próximos eventos', reporter.channel_title
    end
    
end
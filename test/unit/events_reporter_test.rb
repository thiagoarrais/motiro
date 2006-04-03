require File.dirname(__FILE__) + '/../test_helper'

require 'reporters/events_reporter'

class EventsReporterTest < Test::Unit::TestCase

    fixtures :headlines

    def test_channel_title
        reporter = EventsReporter.new
        
        assert_equal 'Próximos eventos', reporter.channel_title
    end
    
    def test_retrieves_from_database
        release_event = headlines('release_event')
        meeting_event = headlines('meeting_event')
        reporter = EventsReporter.new
        
        headlines = reporter.latest_headlines

        assert headlines.include?(release_event)
        assert headlines.include?(meeting_event)
    end
    
end
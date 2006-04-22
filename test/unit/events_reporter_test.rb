require File.dirname(__FILE__) + '/../test_helper'

require 'reporters/events_reporter'

class EventsReporterTest < Test::Unit::TestCase

    fixtures :headlines

    def setup
        @reporter = EventsReporter.new
    end

    def test_channel_title
        assert_equal 'Próximos eventos', @reporter.channel_title
    end
    
    def test_retrieves_from_database
        release_event = headlines('release_event')
        meeting_event = headlines('meeting_event')
        
        headlines = @reporter.latest_headlines

        assert headlines.include?(release_event)
        assert headlines.include?(meeting_event)
    end
    
    def test_article_for
        release_event = headlines('release_event')
        release_event_article = headlines('release_event')
        article = @reporter.article_for release_event.rid
        
        assert_equal release_event_article.description, article.description    
    end
    
end
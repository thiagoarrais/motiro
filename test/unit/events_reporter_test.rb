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
    
    def test_headline_method
        release_event = headlines('release_event')
        headline = @reporter.headline release_event.rid
        
        assert_equal release_event.description, headline.description    
    end
    
    def test_store_event_saves_to_db
        Headline.destroy_all
        @reporter.store_event(:title => 'Next release',
                              :happened_at => Time.local(2006, 4, 26),
                              :description => 'Next release from Motiro',
                              :author => 'thiagoarrais')
                                             
        assert_not_nil Headline.find(:first,
                                     :conditions => "title = 'Next release'")
    end
    
    def test_store_event_assigns_unique_rid_and_reported_by
        fst_headline = @reporter.store_event(:title => 'Next release',
                                             :happened_at => Time.local(2006, 4, 26),
                                             :description => 'Next release from Motiro',
                                             :author => 'thiagoarrais')

        assert_not_empty fst_headline.rid
        
        snd_headline = @reporter.store_event(:title => 'Party',
                                             :happened_at => Time.local(2006, 4, 28),
                                             :description => "Let's celebrate",
                                             :author => 'thiagoarrais')
        
        assert_not_equal fst_headline, snd_headline
        assert_not_empty snd_headline.reported_by
    end
    
private
    
    def assert_not_empty(str)
        assert_not_nil str
        assert_not_equal '', str
    end
    
end
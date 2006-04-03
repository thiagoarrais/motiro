require 'reporters/svn_settings'
require 'reporters/svn_reporter'
require 'reporters/events_reporter'
require 'models/headline'

require 'core/cache_reporter'


# The ChiefEditor is the guy that makes all the reporters work
class ChiefEditor

    def initialize(settings=SubversionSettingsProvider.new)
        @settings = settings
        @reporters = Hash.new
        @strategy = create_strategy
                
        #TODO Maybe we'll need something like a reporter fetcher that updates
        #     the reporter list at server startup time
        #     Or maybe the reporters can be 'require'd dinamically as needed
        self.employ(SubversionReporter.new)
        self.employ(EventsReporter.new)
    end

    def latest_news_from(reporter_name)
        @strategy.latest_news_from(reporter_name)
    end
    
    def article_for_headline(reporter_name, rid)
        @strategy.article_for_headline(reporter_name, rid)
    end
    
    def title_for(reporter_name)
        reporter = @reporters[reporter_name]
        return reporter.channel_title
    end
    
    # Adds the given reporter to the set of reporters employed by the editor
    def employ(reporter)
        @reporters.update(reporter.name => reporter)
    end

private
    
    def create_strategy
        if (@settings.getUpdateInterval == 0) then
            return LiveEditorStrategy.new(@reporters)
        else
            return CachedEditorStrategy.new(@settings)
        end 
    end
    
end

class LiveEditorStrategy

    def initialize(reporter_map)
        @reporters = reporter_map
    end
    
    def latest_news_from(reporter_name)
        reporter = @reporters[reporter_name]
        return reporter.latest_headlines
    end
    
    def article_for_headline(reporter_name, rid)
        reporter = @reporters[reporter_name]
        return reporter.article_for(rid)
    end

end

class CachedEditorStrategy
    
    def initialize(settings)
        @settings = settings
    end

    def latest_news_from(reporter_name)
        reporter = CacheReporter.new(reporter_name, @settings)
        return reporter.latest_headlines
    end    
    
    def article_for_headline(reporter_name, rid)
        headline =  Headline.find_with_reporter_and_rid(reporter_name, rid)
        return headline.article
    end

end
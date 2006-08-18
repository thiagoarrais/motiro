require 'reporters/svn_settings'
require 'reporters/events_reporter'
require 'models/headline'

require 'core/cache_reporter'
require 'core/reporter_fetcher'
require 'core/settings'

# The ChiefEditor is the guy that makes all the reporters work
class ChiefEditor

    def initialize(settings=SettingsProvider.new, fetcher=ReporterFetcher.new)
        @settings = settings
        @reporters = Hash.new
        @strategy = create_strategy
                
        fetcher.active_reporters.each do |reporter|
          self.employ(reporter)
        end

        self.employ(EventsReporter.new)
    end

    def latest_news_from(reporter_name)
        @strategy.latest_news_from(reporter_name)
    end
    
    def headline_with(reporter_name, rid)
        @strategy.headline_with(reporter_name, rid)
    end
    
    def title_for(reporter_name)
        reporter = @reporters[reporter_name]
        return reporter.channel_title
    end
    
    def toolbar_for(reporter_name)
        reporter = @reporters[reporter_name]
        return reporter.toolbar
    end
    
    # Adds the given reporter to the set of reporters employed by the editor
    def employ(reporter)
        @reporters.update(reporter.name => reporter)
    end

private
    
    def create_strategy
        if (@settings.update_interval == 0) then
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
    
    def headline_with(reporter_name, rid)
        reporter = @reporters[reporter_name]
        return reporter.headline(rid)
    end

end

class CachedEditorStrategy
    
    def initialize(settings)
        @settings = settings
    end

    def latest_news_from(name)
        return reporter_with(name).latest_headlines
    end    
    
    def headline_with(name, rid)
        return reporter_with(name).headline(rid)
    end
    
private
    
    def reporter_with(name)
        return CacheReporter.new(name, @settings)
    end

end
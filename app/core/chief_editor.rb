require 'reporters/svn_settings'
require 'reporters/svn_reporter'
require 'models/headline'

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
    end

    def latest_news_from(reporter_name)
        @strategy.latest_news_from(reporter_name)
    end
    
    def article_for_headline(reporter_name, rid)
        @strategy.article_for_headline(reporter_name, rid)
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
        return Headline.latest(@settings.getPackageSize)
    end    
    
    def article_for_headline(reporter_name, rid)
        headline=  Headline.find(:first,
                                 :conditions => ["reported_by = ? " +
                                                 "and rid = ?",
                                                 reporter_name,
                                                 rid])
        return headline.article
    end

end
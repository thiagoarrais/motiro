require 'reporters/svn_settings'
require 'reporters/svn_reporter'
require 'models/headline'

# The ChiefEditor is the guy that makes all the reporters work
class ChiefEditor

    def initialize(settings=SubversionSettingsProvider.new)
        @settings = settings
        @reporters = Hash.new

        #TODO Maybe we'll need something like a reporter fetcher that updates
        #     the reporter list at server startup time
        #     Or maybe the reporters can be 'require'd dinamically as needed
        self.employ(SubversionReporter.new)
    end

    def latest_news_from(reporter_name)
        if (@settings.getUpdateInterval == 0) then
            # we're in development mode
            # every request should be routed directly to the reporter
            reporter = @reporters[reporter_name]
            return reporter.latest_headlines
        else 
            return Headline.latest @settings.getPackageSize
        end
    end
    
    # Adds the given reporter to the set of reporters employed by the editor
    def employ(reporter)
        @reporters.update(reporter.name => reporter)
    end

end
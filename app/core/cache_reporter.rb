# A cache reporter is a reporter that just repeats news discovered by real
# reporters
#
# Every cache reporter has a real reporter that it tries to mimic. This type
# of reporter will go to the news database and retrieve all news that its real
# correspondent reported.
class CacheReporter < MotiroReporter

    def initialize( reporter,
                    settings=SubversionSettingsProvider.new,
                    headlines_source=Headline)
        @headlines_source = headlines_source
        @settings = settings
        @source_reporter_name = reporter
    end

    def latest_headlines
        return @headlines_source.latest(@settings.getPackageSize, @source_reporter_name)
    end
    
    def article_for(rid)
        headline =  @headlines_source.find_with_reporter_and_rid(@source_reporter_name, rid)
        return headline.article
    end

end
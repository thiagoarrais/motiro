require 'reporters/svn_settings'
require 'models/headline'

# The ChiefEditor is the guy that makes all the reporters work
class ChiefEditor

    def initialize(settings=SubversionSettingsProvider.new)
        @settings = settings
    end

    def latest_news_from(reporter)
        Headline.latest @settings.getPackageSize
    end

end
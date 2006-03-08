require 'models/headline'

require 'reporters/svn_settings'

class ReportController < ApplicationController

    def initialize(settings=SubversionSettingsProvider.new)
        @settings = settings
    end

    def subversion
        reporter = SubversionReporter.new
        @headlines = Headline.latest @settings.getPackageSize
    end

end

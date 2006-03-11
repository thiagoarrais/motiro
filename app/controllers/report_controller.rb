require 'models/headline'

require 'reporters/svn_settings'

class ReportController < ApplicationController

    def initialize(settings=SubversionSettingsProvider.new)
        @settings = settings
        @reporters = { 'subversion' => SubversionReporter.new }
    end

    def subversion
        reporter = @reporters
        @headlines = Headline.latest @settings.getPackageSize
    end
    
    def show
        reporter = @reporters[params[:reporter]]
        @headlines = Headline.latest @settings.getPackageSize
        render(:action => params[:format])
    end
    
end

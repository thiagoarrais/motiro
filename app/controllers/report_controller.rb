require 'models/headline'

require 'reporters/svn_settings'

class ReportController < ApplicationController

    def initialize(settings=SubversionSettingsProvider.new)
        @settings = settings
        @reporters = { 'subversion' => SubversionReporter.new }
    end

    def show
        reporter = @reporters[params[:reporter]]
        format = params[:format] || 'html_fragment'
        @headlines = Headline.latest @settings.getPackageSize
        render(:action => format)
    end
    
end

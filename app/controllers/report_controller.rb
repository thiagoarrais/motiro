require 'models/headline'

class ReportController < ApplicationController

    def subversion
        reporter = SubversionReporter.new
        @headlines = Headline.latest 5
    end

end

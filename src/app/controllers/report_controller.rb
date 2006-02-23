require 'reporters/svn_reporter'

class ReportController < ApplicationController

    def subversion
        reporter = SubversionReporter.new
        @headlines = reporter.latest_headlines(5)
    end

end

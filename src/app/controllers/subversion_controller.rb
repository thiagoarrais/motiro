require 'reporters/svn_reporter'

class SubversionController < ApplicationController

    def report
        reporter = SubversionReporter.new
        @headlines = reporter.latest_headlines(5)
    end

end

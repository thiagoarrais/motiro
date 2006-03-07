require 'reporters/svn_reporter'

class SubversionDriver

    def initialize(reporter = SubversionReporter.new)
        @reporter = reporter
    end

    def tick
        #TODO need to parametrize the number of headlines
        hls = @reporter.latest_headlines 5
        hls.each do |hl|
            hl.save
        end
    end

end
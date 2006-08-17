require 'reporters/subversion_reporter'

require 'headline'

class SubversionDriver

    def initialize(reporter = SubversionReporter.new)
        @reporter = reporter
    end

    def tick
        hls = @reporter.latest_headlines
        
        hls.each do |hl|
            hl.cache
        end
    end

end
class SubversionDriver

    def initialize(reporter)
        @reporter = reporter
    end

    def tick
        hls = @reporter.latest_headlines
        hls.each do |hl|
            hl.save
        end
    end

end
require 'reporters/svn_reporter'

require 'headline'

class SubversionDriver

    def initialize(reporter = SubversionReporter.new)
        @reporter = reporter
    end

    def tick
        hls = @reporter.latest_headlines
        
        hls.each do |hl|
            #TODO move this to the headline class itself
            cached_lines = Headline.find(:all,
                               :conditions => "author = '#{hl.author}' " +
                                              "and title = '#{hl.title}'")
                         
            hl.save if (cached_lines.empty? || !cached_lines.collect do |line| hl.event_date == line.event_date end.include?(true) )
        end
    end

end
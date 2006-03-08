require 'reporters/svn_reporter'

require 'headline'

class SubversionDriver

    def initialize(reporter = SubversionReporter.new)
        @reporter = reporter
    end

    def tick
        #TODO need to parametrize the number of headlines
        hls = @reporter.latest_headlines 5
        
        hls.each do |hl|
            #TODO move this to the headline class itself
            rs = Headline.find(:all,
                      :conditions => "    author = '#{hl.author}' " +
                                     "and event_date = '#{hl.event_date}' " +
                                     "and title = '#{hl.title}'")
                                     
            hl.save if rs.empty?
        end
    end

end
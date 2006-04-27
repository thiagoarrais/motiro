require 'core/cache_reporter'

class EventsReporter < CacheReporter
    title 'Próximos eventos'
    
    def initialize
        super('events')
    end
    
    def store_event(params)
        headline = Headline.new(params)
        
        previous_hl = 0
        until previous_hl.nil?
          id = (rand * 100000).to_i
          previous_hl = Headline.find(:first,
                          :conditions => ["reported_by = 'events' and rid = ?",
                                          "e#{id}"])
        end
        
        headline.rid = "e#{id}"
        headline.reported_by = name
        
        headline.save
        
        return headline
    end
    
    
end
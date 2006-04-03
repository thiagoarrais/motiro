require 'core/cache_reporter'

class EventsReporter < CacheReporter
    title 'Próximos eventos'
    
    def initialize
        super('events')
    end
end
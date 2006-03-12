class Headline < ActiveRecord::Base

    def self.latest(num)
        find(:all,
             :order => 'event_date DESC',
             :limit => num)
    end
    
    def event_date=(date_components)
        year, month, day, hour, min, sec = date_components
        self[:event_date] = Time.local(year, month, day, hour, min, sec)
    end
    
    def cached?
        cached_lines = Headline.find(:all,
                           :conditions => ["author = ? " +
                                           "and title = ?" +
                                           "and event_date =?",
                                           self.author,
                                           self.title,
                                           self.event_date])
            
        return ! cached_lines.empty?
    end

end

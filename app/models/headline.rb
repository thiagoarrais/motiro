class Headline < ActiveRecord::Base

    has_one :article

    def self.latest(num)
        find(:all,
             :order => 'happened_at DESC',
             :limit => num)
    end
    
    def happened_at=(date_components)
        year, month, day, hour, min, sec = date_components
        self[:happened_at] = Time.local(year, month, day, hour, min, sec)
    end
    
    # Saves the headline locally, if it isn't already cached
    def cache
        self.save unless self.cached?
    end

    def cached?
        cached_lines = Headline.find(:all,
                           :conditions => ["author = ? " +
                                           "and title = ?" +
                                           "and happened_at =?",
                                           self.author,
                                           self.title,
                                           self.happened_at])
            
        return ! cached_lines.empty?
    end
    
end

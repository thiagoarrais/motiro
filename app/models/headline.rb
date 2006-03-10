require 'date'

class Time
    def to_t
        self
    end 
end

class DateTime
    def to_t
        Time.local(self.year, self.month, self.day,
                   self.hour, self.min, self.sec)
    end
end

class Headline < ActiveRecord::Base

    def self.latest(num)
        find(:all,
             :order => 'event_date DESC',
             :limit => num)
    end
    
    def cached?
        cached_lines = Headline.find(:all,
                           :conditions => "author = '#{self.author}' " +
                                          "and title = '#{self.title}'")
            
        question_results = cached_lines.collect do |line|
            self.event_date.to_t == line.event_date.to_t
        end                         

        return !(cached_lines.empty? || !question_results.include?(true) )
    end

end

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
                           :conditions => "author = '#{self.author}' " +
                                          "and title = '#{self.title}'")
            
        question_results = cached_lines.collect do |line|
            self.event_date == line.event_date
        end                         

        return !(cached_lines.empty? || !question_results.include?(true) )
    end

end

class Headline < ActiveRecord::Base

    def self.latest(num)
        find(:all,
             :order => 'event_date DESC',
             :limit => num)
    end

end

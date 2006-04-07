class Headline < ActiveRecord::Base

    has_one :article
    
    def initialize(params={})
        super(params)
        self.article = Article.new
    end

    def self.latest(num, reporter)
        find(:all,
             :conditions => ["reported_by = ?", reporter],
             :order => 'happened_at DESC',
             :limit => num)
    end
    
    def self.find_with_reporter_and_rid(reporter_name, rid)
        find(:first,
             :conditions => ["reported_by = ? and rid = ?",
                             reporter_name, rid])        
    end    


    def happened_at=(date_components)
        year, month, day, hour, min, sec = date_components
        self[:happened_at] = Time.local(year, month, day, hour, min, sec)
    end
    
    # Saves the headline locally, if it isn't already cached
    def cache
        unless self.cached?
            # TODO duplicate code
            self.class.destroy_all(["author = ? " +
                                    "and title = ?" +
                                    "and happened_at =?",
                                    self.author,
                                    self.title,
                                    self.happened_at])
            self.save
        end
    end

    def cached?
        cached_lines = Headline.find(:all,
                           :conditions => ["author = ? " +
                                           "and title = ?" +
                                           "and happened_at =?",
                                           self.author,
                                           self.title,
                                           self.happened_at])
                                           
        return false if cached_lines.empty?
            
        cached_lines.each do |hl| 
            return true if hl.filled?
        end

        return false
    end
    
    def filled?
        self.article.changes.each do |c|
            return false if !c.filled?
        end
        
        return true
    end
    
end

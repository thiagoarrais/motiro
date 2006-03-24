class Article < ActiveRecord::Base

    has_many :changes
    
    def summary
        changes.join("\n")
    end

end

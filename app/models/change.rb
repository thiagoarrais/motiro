class Change < ActiveRecord::Base

    def to_s
        return summary
    end
    
    def resource_name
        return summary.split('/').last
    end

end

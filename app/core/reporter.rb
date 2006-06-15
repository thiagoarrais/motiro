require 'rubygems'
require 'active_support'

# A reporter is someone capable of going out for news
#
# For a Motiro reporter, "going out" may include, but is not limited to,
# accessing the local file system, executing external processes and consulting
# the web
class MotiroReporter

    def self.reporter_name
        class_name = self.name
        return class_name[0, class_name.size - 8].underscore
    end
    
    # Replaces the default title with a custom one. Example usage:
    #
    #       class MyReporter < MotiroReporter
    #           title "This is my reporter's custom title"
    #       end
    #       
    #       MyReporter.new.channel_title => "This is my reporter's custom title"
    #
    # If not called, a default title will be generated based on the class name
    def self.title(title)
        define_method :channel_title do
            title.t
        end
    end

    def name
        return self.class.reporter_name
    end

    def channel_title
        return 'Latest news from %s' / name.humanize
    end
    
    def latest_headline
        return latest_headlines.first
    end
    
    def latest_headlines; end
    
end
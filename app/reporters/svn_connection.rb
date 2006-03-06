require 'core/runner'
require 'reporters/svn_settings'

class SubversionConnection
    
    def initialize
        initialize(SubversionSettingsProvider.new, Runner.new)
    end

    def initialize(settings=SubversionSettingsProvider.new, runner=Runner.new)
        @settings, @runner = settings, runner
    end

    #TODO parametize the revision list size
    def log
        @runner.run "svn log #{@settings.getRepoURL}"
    end
    
end                                                           
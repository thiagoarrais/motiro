require 'ports/runner'
require 'reporters/svn_settings'

class SubversionConnection
    
    def initialize
        initialize(SubversionSettingsProvider.new, Runner.new)
    end

    def initialize(settings=SubversionSettingsProvider.new, runner=Runner.new)
        @settings, @runner = settings, runner
    end

    def log
        @runner.run "svn log -v --limit=#{@settings.getPackageSize} " +
                    "#{@settings.getRepoURL}"
    end
    
end                                                           
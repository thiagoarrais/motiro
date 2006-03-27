require 'ports/runner'
require 'reporters/svn_settings'

class SubversionConnection
    
    def initialize
        initialize(SubversionSettingsProvider.new, Runner.new)
    end

    def initialize(settings=SubversionSettingsProvider.new, runner=Runner.new)
        @settings, @runner = settings, runner
    end

    def log(rev_id=nil)
        command = "svn log #{@settings.getRepoURL} -v "
        if rev_id.nil? 
            command += "--limit=#{@settings.getPackageSize}"
        else
            command += "-r#{rev_id.to_s}"
        end
        
        @runner.run command
    end
    
    def diff(rev_id)
        command = "svn diff #{@settings.getRepoURL} -r#{rev_id.to_i - 1}:#{rev_id}"

        @runner.run command
    end
    
end                                                           
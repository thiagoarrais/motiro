require 'ports/runner'
require 'reporters/svn_settings'

class SubversionConnection
    
    def initialize(settings=SubversionSettingsProvider.new, runner=Runner.new)
        @settings, @runner = settings, runner
        @diff_cache = Hash.new
    end

    def log(rev_id=nil)
        command = "svn log #{@settings.repo_url} -v "
        if rev_id.nil? 
            command += "--limit=#{@settings.package_size}"
        else
            command += "-r#{rev_id.to_s}"
        end
        
        @runner.run command
    end
    
    def diff(rev_id)
        cached_result = @diff_cache[rev_id]
        
        if cached_result.nil?
            command = "svn diff #{@settings.repo_url} -r#{rev_id.to_i - 1}:#{rev_id}"
    
            cached_result = @runner.run command
            @diff_cache[rev_id] = cached_result
        end
        
        return cached_result
    end
    
    def info(path, rev_id)
        command = "svn info -r#{rev_id} --xml #{@settings.repo_url}#{path}"
        @runner.run(command)
    end
    
end                                                           
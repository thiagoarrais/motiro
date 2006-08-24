require 'stringio'

require 'ports/runner'
require 'reporters/darcs_settings'

class DarcsConnection

  def initialize(settings=DarcsSettingsProvider.new, runner=Runner.new)
    @settings, @runner = settings, runner
  end
  
  def changes(hashcode=nil)
    command = 'darcs changes --xml '
    if hashcode then
      command += "--from-match=\"hash #{hashcode}\" " +
                 "--to-match=\"hash #{hashcode}\" "
    else
      command += "--last=#{@settings.package_size} "
    end
    command += "--repo=#{@settings.repo_url}"
    @runner.run(command)
  end

end
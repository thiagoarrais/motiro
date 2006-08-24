require 'stringio'

require 'ports/runner'
require 'reporters/darcs_settings'

class DarcsConnection

  def initialize(settings=DarcsSettingsProvider.new, runner=Runner.new)
    @settings, @runner = settings, runner
  end
  
  def changes(hashcode=nil)
    command = 'darcs changes --xml '
    command += "--from-match=\"hash #{hashcode}\" " +
               "--to-match=\"hash #{hashcode}\" " unless hashcode.nil?
    command += "--repo=#{@settings.repo_url}"
    @runner.run(command)
  end

end
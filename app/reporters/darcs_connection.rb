require 'stringio'

require 'ports/runner'
require 'reporters/darcs_settings'
require 'reporters/darcs_temp_repo'

class DarcsConnection

  def initialize(settings=DarcsSettingsProvider.new,
                 runner=Runner.new,
                 temp_repo = DarcsTempRepo.new)
    @settings, @runner, @repo = settings, runner, temp_repo
  end
  
  def changes(hashcode=nil)
    command = 'darcs changes --xml '
    if hashcode then
      command += "--from-match=\"hash #{hashcode}\" " +
                 "--to-match=\"hash #{hashcode}\" "
    else
      command += "--last=#{@settings.package_size} "
    end
    command += "--repo=#{@settings.repo_url} --repodir=#{@repo.path}"
    @runner.run(command)
  end

end
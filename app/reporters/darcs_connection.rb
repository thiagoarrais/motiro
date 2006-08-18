require 'stringio'

require 'ports/runner'
require 'reporters/darcs_settings'

class DarcsConnection

  def initialize(settings=DarcsSettingsProvider.new, runner=Runner.new)
    @settings, @runner = settings, runner
  end
  
  def changes
    @runner.run("darcs changes --xml --repo=#{@settings.repo_url}")
  end

end
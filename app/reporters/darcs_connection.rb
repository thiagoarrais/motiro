#  Motiro - A project tracking tool
#  Copyright (C) 2006-2008  Thiago Arrais
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

require 'stringio'

require 'ports/runner'
require 'ports/chdir_runner'

require 'reporters/darcs_settings'
require 'reporters/darcs_temp_repo'

class DarcsConnection

  def initialize(settings=DarcsSettingsProvider.new,
                 runner=Runner.new,
                 temp_repo = DarcsTempRepo.new)
    @settings = settings
    @runner = ChdirRunner.new(temp_repo.path, runner)
  end
  
  def changes(options=nil)
    command = 'darcs changes --xml'
    if options.nil?
      command += " --last=#{@settings.package_size}"
    elsif :all != options
      command += " --from-match=\"hash #{options}\"" +
                 " --to-match=\"hash #{options}\""
    end
    @runner.run(command)
  end
  
  def pull
    @runner.run("darcs pull -a #{@settings.repo_url}")
  end
  
  def diff(patch_hash)
    @runner.run("darcs diff -u --match \"hash #{patch_hash}\"")
  end

end
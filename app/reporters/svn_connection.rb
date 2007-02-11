#  Motiro - A project tracking tool
#  Copyright (C) 2006-2007  Thiago Arrais
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

require 'ports/runner'
require 'reporters/svn_settings'

class SubversionConnection
  
  def initialize(settings=SubversionSettingsProvider.new, runner=Runner.new)
    @settings = settings
    @runner = FixedParameterRunner.new(runner, "t\n", 'LC_MESSAGES' => 'C')
    @diff_cache = Hash.new
  end
  
  def log(options=nil)
    command = "log #{@settings.repo_url} -v"

    if options.nil?
      command += " --limit=#{@settings.package_size}"
    elsif :all != options
      command += " -r#{options.to_s}"
    end
    
    svn(command)
  end
  
  def diff(rev_id)
    @diff_cache[rev_id] ||= svn("diff #{@settings.repo_url} -r#{rev_id.to_i - 1}:#{rev_id}")
  end
  
  def info(path, rev_id)
    svn("info -r#{rev_id} --xml #{@settings.repo_url}#{path}")
  end
  
private

  def svn(command)
    credentials = @settings.repo_user ?
                    "--username='#{@settings.repo_user}' --password='#{@settings.repo_password}' " :
                    ''
    
    @runner.run("svn " + credentials + command)
  end
  
end                                                           

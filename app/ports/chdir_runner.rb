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

require 'ports/runner'

class ChdirRunner

  def initialize(dir, runner=Runner.new)
    @dir, @runner = dir, runner
  end
  
  def run(command, input='', env={})
    prevdir = Dir.pwd
    begin
      Dir.chdir(@dir)
      @runner.run(command, input, env)
    ensure
      Dir.chdir(prevdir)
    end
  end

end
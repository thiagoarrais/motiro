#  Motiro - A project tracking tool
#  Copyright (C) 2006  Thiago Arrais
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

class Runner

  def run(command, env={})
    commons = {}
    env.each_key do |k|
      commons[k] = ENV[k] if ENV.has_key?(k)
    end
    ENV.update env

    result = `#{command}`

    env.each_key do |k|
      ENV.delete k
    end
    commons.each do |k, v|
      ENV[k] = v
    end
    
    return result
  end

end

class CustomEnvironmentRunner
  
  def initialize(underlying_runner, env)
    @runner, @env = underlying_runner, env
  end
  
  def run(command)
    @runner.run(command, @env)
  end
  
end

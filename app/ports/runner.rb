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

class Runner

  def initialize(process_creator=IO)
    @creator = process_creator
  end
  
  def run(command, input='', env={})
    commons = {}
    env.each_key do |k|
      commons[k] = ENV[k] if ENV.has_key?(k)
    end
    ENV.update env

    process = @creator.popen(command, 'r+')
    begin
      process << input
      process.flush
    rescue
      #ignore i/o errors
    end

    env.each_key do |k|
      ENV.delete k
    end
    commons.each do |k, v|
      ENV[k] = v
    end

    result = process.read
    process.close
    
    return result    
  end

end

class FixedParameterRunner
  
  def initialize(underlying_runner, input, env)
    @runner, @input, @env = underlying_runner, input, env
  end
  
  def run(command)
    @runner.run(command, @input, @env)
  end
  
end

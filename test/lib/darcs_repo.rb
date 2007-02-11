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

require 'fileutils'
require 'repoutils'
require 'webserver'

include FileUtils

class DarcsRepository

  attr_reader :dir, :url, :author
  
  def initialize(options=:http)
    @url = @dir = find_root_dir('darcs')
    if (:http == options)
      @server = WebServer.create_http_server_on(self.dir)
      @url = 'http://localhost:' + @server[:Port].to_s
    end
    @author = 'alceu.valenca@olinda.pe.br'
    mkdir_p(self.dir)
    run_on_repo { `darcs init` }
  end
  
  def add_file(name, contents)
    file_path = "#{self.dir}/#{name}"
    
    File.open(file_path, 'w') do |file|
      file << contents
    end
    
    run_on_repo { `darcs add #{name}` }
  end
  
  def record(patch_text)
    temp_file = TEMP_DIR + '/darcs-msg.motiro'
    File.open(temp_file, 'w') do |file|
      file << patch_text
    end

    run_on_repo { `darcs record -a --logfile="#{temp_file}" --author="#{self.author}" 2>&1` }
  end
  
  def destroy
    @server.shutdown if !@server.nil?
    rm_rf(self.dir)
  end
  
private

  def run_on_repo
    previous = Dir.pwd
    begin
      Dir.chdir(self.dir)
      yield
    ensure
      Dir.chdir(previous)
    end
  end

  include RepoUtils

end

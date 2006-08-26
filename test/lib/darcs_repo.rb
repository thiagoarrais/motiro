require 'fileutils'
require 'repoutils'
require 'webrick'

include FileUtils

class DarcsRepository

  attr_reader :dir, :url, :author
  
  def initialize
    @dir = find_root_dir('darcs')
    @server = create_http_server_on(self.dir)
    @url = 'http://localhost:' + @server.config[:Port].to_s
    @author = 'alceu.valenca@olinda.pe.br'
    mkdir_p(self.dir)
    `darcs init --repodir=#{self.dir}`
  end
  
  def add_file(name, contents)
    file_path = "#{self.dir}/#{name}"
    
    File.open(file_path, 'w') do |file|
      file << contents
    end
    
    `darcs add --repo=#{self.dir} #{file_path}`
  end
  
  def record(patch_text)
    temp_file = ENV['TEMP'] + '/darcs-msg.motiro'
    File.open(temp_file, 'w') do |file|
      file << patch_text
    end
    `darcs record -a --logfile=#{temp_file} --repodir=#{self.dir} --author=\"#{self.author}\" 2>&1`
  end
  
  def destroy
    @server.shutdown
    rm_rf(self.dir)
  end
  
private

  def create_http_server_on(document_root)
    port = find_available_port
    server = WEBrick::HTTPServer.new :Port => port,
                                     :DocumentRoot => document_root,
                                     :Logger => NullLogger.new,
                                     :AccessLog => [ [NullLogger.new, WEBrick::AccessLog::COMBINED_LOG_FORMAT] ]
    Thread.new do
      server.start
    end
    
    return server
  end

  include RepoUtils

end

class NullLogger
  def method_missing(name, *args); end
end
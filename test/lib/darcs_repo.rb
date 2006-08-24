require 'fileutils'
require 'repoutils'

include FileUtils

class DarcsRepository

  attr_reader :url, :author
  
  def initialize
    @url = find_root_dir('darcs')
    @author = 'alceu.valenca@olinda.pe.br'
    mkdir_p(self.url)
    `darcs init --repodir=#{self.url}`
  end
  
  def add_file(name, contents)
    file_path = "#{self.url}/#{name}"
    
    File.open(file_path, 'w') do |file|
      file << contents
    end
    
    `darcs add --repo=#{self.url} #{file_path}`
  end
  
  def record(patch_text)
    temp_file = ENV['TEMP'] + '/darcs-msg.motiro'
    File.open(temp_file, 'w') do |file|
      file << patch_text
    end
    `darcs record -a --logfile=#{temp_file} --repodir=#{self.url} --author=\"#{self.author}\" 2>&1`
  end
  
  def destroy
    rm_rf(self.url)
  end

private

  include RepoUtils

end
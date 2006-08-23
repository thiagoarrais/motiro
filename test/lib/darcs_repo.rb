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
  
  def record(patch_title)
    `darcs record -am\"#{patch_title}\" --repodir=#{self.url} 2>&1 --author=\"#{self.author}\"`
  end
  
  def destroy
    rm_rf(self.url)
  end

private

  include RepoUtils

end
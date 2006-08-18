require 'fileutils'
require 'repoutils'

include FileUtils

class DarcsRepository

  attr_reader :url
  
  def initialize
    @url = find_root_dir('darcs')
    mkdir_p(self.url)
    `darcs init --repodir=#{self.url}`
  end
  
  def destroy
    rm_rf(self.url)
  end

private

  include RepoUtils

end
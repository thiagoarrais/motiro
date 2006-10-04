require 'fileutils'
require 'ports/runner'

# This class is part of a workaround for darcs bug #250
# Darcs somehow needs to have a local repo to retrieve the changelog from a
# repo behind an HTTP server
# 
# For more details see http://bugs.darcs.net/issue250
class DarcsTempRepo

  attr_reader :path

  def initialize(filesystem=File, fileutils=FileUtils, runner=Runner.new)
    @path = File.expand_path(__FILE__ + '../../../../tmp/tmprepo')
    unless filesystem.exists?(@path + '/_darcs')
      fileutils.mkdir_p(@path)
      runner.run("darcs init --repodir=\"#{@path}\"")
    end
  end

end
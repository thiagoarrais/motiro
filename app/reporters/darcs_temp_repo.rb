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

require 'fileutils'
require 'ports/chdir_runner'

# This class is part of a workaround for darcs bug #250
# Darcs somehow needs to have a local repo to retrieve the changelog from a
# repo behind an HTTP server
# 
# For more details see http://bugs.darcs.net/issue250
class DarcsTempRepo

  @@path = File.expand_path(__FILE__ + '../../../../tmp/tmprepo')

  def initialize(filesystem=File, fileutils=FileUtils,
                 runner=ChdirRunner.new(@@path))
    unless filesystem.exists?(path + '/_darcs')
      fileutils.mkdir_p(path)
      runner.run("darcs init")
    end
  end

  def path; @@path; end

end

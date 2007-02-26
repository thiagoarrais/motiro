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

require 'rubygems'
require 'fileutils'

$:.push File.expand_path(File.dirname(__FILE__) + '/../lib')
$:.push File.expand_path(File.dirname(__FILE__) + '/../../app')
$:.push File.expand_path(File.dirname(__FILE__) + '/../../vendor')

require 'repoutils'
require 'darcs_repo'
require 'reporters/darcs_temp_repo'

require 'test/unit'

# What we expect from the `darcs' command line client
class RemoteDarcsTest < Test::Unit::TestCase

  include RepoUtils
  
  def setup
    @repo = DarcsRepository.new
    @tmp = find_root_dir('ldarcs')
    @previous_dir = Dir.pwd
    FileUtils.mkdir_p(@tmp)
    Dir.chdir(@tmp)
    `darcs init`
    Dir.chdir(@previous_dir)
  end

  def test_pulling
    @repo.add_file('my_file.txt', 'file contents')
    @repo.record('adds a file')
    
    Dir.chdir(@tmp)
    `darcs pull -a #{@repo.url}`
    assert `darcs changes`.match(/adds a file/)
  end
  
  def teardown
    Dir.chdir(@previous_dir)
    FileUtils.rm_rf(@tmp)
    @repo.destroy
  end

end

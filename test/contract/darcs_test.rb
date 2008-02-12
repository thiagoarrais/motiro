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

$:.push File.expand_path(File.dirname(__FILE__) + '/../lib')

require  'darcs_repo'

require 'rexml/document'
require 'test/unit'

# What we expect from the `darcs' command line client
class LocalDarcsTest < Test::Unit::TestCase

  def setup
    @repo = DarcsRepository.new(:file)
  end

  def test_unified_diff
    @repo.add_file('my_file.txt', 'file contents')
    @repo.record('adds a file')
    
    previous = Dir.pwd
    Dir.chdir(@repo.url)
    output = `darcs changes --xml`
    hash = REXML::Document.new(output).root.elements['patch'].attributes['hash']
    
    output = `darcs diff -u --match="hash #{hash}"`
    Dir.chdir(previous)
    assert output.match(/^diff/)
    assert output.match(/^--- old/)
  end
  
  def teardown
    @repo.destroy
  end

end

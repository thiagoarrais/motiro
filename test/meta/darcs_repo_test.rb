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

require File.dirname(__FILE__) + '/../test_helper'

require 'fileutils'
require 'darcs_repo'

class DarcsRepositoryTest < Test::Unit::TestCase

  def test_default_repo_url_is_http_location
    repo = DarcsRepository.new
    
    assert repo.url.match(/^http:/)
    
    repo.destroy
  end
  
  def test_filesystem_repo_does_not_use_http
    repo = DarcsRepository.new(:file)

    assert !repo.url.match(/^http/)

    repo.destroy
  end

  def test_different_repos_have_different_urls
    fst_repo = DarcsRepository.new
    snd_repo = DarcsRepository.new
    
    assert_not_equal fst_repo.url, snd_repo.url
    
    fst_repo.destroy
    snd_repo.destroy
  end
  
  def test_repo_url_really_points_to_a_darcs_repo
    repo = DarcsRepository.new
    
    assert is_repo?(repo.url)
    
    repo.destroy
  end
  
  def test_destroy_removes_dir
    repo = DarcsRepository.new
    
    assert is_repo?(repo.dir)
    
    repo.destroy

    assert !is_repo?(repo.dir)
  end
  
  def test_adding_file
    repo = DarcsRepository.new
    file_name = 'fileOne.txt'

    repo.add_file(file_name, 'unimportant')
    
    assert File.exists?(repo.dir + '/' + file_name)
    output = `darcs whatsnew --no-summary --look-for-adds --repo=#{repo.dir} 2>&1`
    assert output.match(/addfile/)
    assert output.match(/#{file_name}/)
    
    repo.destroy
  end
  
  def test_recording_and_author_name
    repo = DarcsRepository.new
    patch_title = 'This is the first patch ever'

    repo.add_file('fileOne.txt', 'unimportant')
    repo.record(patch_title)
    
    assert `darcs whatsnew --repo=#{repo.dir} 2>&1`.match(/No changes!/)
    output = `darcs changes --repo=#{repo.dir} 2>&1`
    assert output.match(/#{patch_title}/)
    assert output.match(/#{repo.author}/)
    
    repo.destroy
  end
  
  def test_recording_with_long_comment
    repo = DarcsRepository.new
    
    repo.add_file('fileTwo.txt', 'file contents')
    repo.record("This is the comment title\n\n" +
                "And these are some details about the patch")

    output = `darcs changes --repo=#{repo.dir}`
    assert output.match(/This is the comment title/)
    assert output.match(/And these are some details about the patch/)
  end
  
private

  def is_repo?(repo_url)
    result = !(`darcs get #{repo_url} tmprepo 2>&1`.match(/Invalid repository/))
    FileUtils.rm_rf('tmprepo')
    return result
  end

end

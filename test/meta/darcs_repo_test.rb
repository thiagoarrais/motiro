require File.dirname(__FILE__) + '/../test_helper'

require 'darcs_repo'

class LocalSubversionRepositoryTest < Test::Unit::TestCase

  def test_different_repos_have_different_urls
    fst_repo = DarcsRepository.new
    snd_repo = DarcsRepository.new
    
    assert_not_equal fst_repo.url, snd_repo.url
    
    fst_repo.destroy
    snd_repo.destroy
  end
  
  def test_repo_url_really_points_to_a_darcs_repo
    repo = DarcsRepository.new
    
    assert !(`darcs changes --repo=#{repo.url} 2>&1`.match(/Not a repository/))
    
    repo.destroy
  end
  
  def test_destroy_removes_dir
    repo = DarcsRepository.new
    
    assert File.exists?(repo.url)
    
    repo.destroy

    assert !File.exists?(repo.url)
  end
  
  def test_adding_file
    repo = DarcsRepository.new
    file_name = 'fileOne.txt'

    repo.add_file(file_name, 'unimportant')
    
    assert File.exists?(repo.url + '/' + file_name)
    output = `darcs whatsnew --no-summary --repo=#{repo.url} 2>&1`
    assert output.match(/addfile/)
    assert output.match(/#{file_name}/)
    
    repo.destroy
  end
  
  def test_recording_and_author_name
    repo = DarcsRepository.new
    patch_title = 'This is the first patch ever'

    repo.add_file('fileOne.txt', 'unimportant')
    repo.record(patch_title)
    
    assert `darcs whatsnew --repo=#{repo.url} 2>&1`.match(/No changes!/)
    output = `darcs changes --repo=#{repo.url} 2>&1`
    assert output.match(/#{patch_title}/)
    assert output.match(/#{repo.author}/)
    
    repo.destroy
  end
  
  def test_recording_with_long_comment
    repo = DarcsRepository.new
    
    repo.add_file('fileTwo.txt', 'file contents')
    repo.record("This is the comment title\n\n" +
                "And these are some details about the patch")

    output = `darcs changes --repo=#{repo.url}`
    assert output.match(/This is the comment title/)
    assert output.match(/And these are some details about the patch/)
  end

end
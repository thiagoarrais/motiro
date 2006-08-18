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

end
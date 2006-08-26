require File.dirname(__FILE__) + '/../test_helper'

require 'reporters/darcs_temp_repo'

class DarcsTempRepoTest < Test::Unit::TestCase

  EXPECTED_PATH = File.expand_path(__FILE__ + '../../../../tmp/tmprepo')

  def test_creates_repodir_on_construction_when_not_created_yet
    FlexMock.use('a', 'b', 'c') do |filesystem, fileutils, runner|
      filesystem.should_receive(:exists?).once.
        with(EXPECTED_PATH + '/_darcs').
        returns(false)
      fileutils.should_receive(:mkdir_p).once.
        with(EXPECTED_PATH)
      runner.should_receive(:run).once.
        with("darcs init --repodir=#{EXPECTED_PATH}")
        
      repo = DarcsTempRepo.new(filesystem, fileutils, runner)
      assert_equal EXPECTED_PATH, repo.path
    end
  end

  def test_does_not_create_repodir_on_construction_when_already_created
    FlexMock.use('a', 'b', 'c') do |filesystem, fileutils, runner|
      filesystem.should_receive(:exists?).once.
        with(EXPECTED_PATH + '/_darcs').
        returns(true)
        
      DarcsTempRepo.new(filesystem, fileutils, runner)
    end
  end

end
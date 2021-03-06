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
        with("darcs init")
        
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

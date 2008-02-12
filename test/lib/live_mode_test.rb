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

require 'configuration'
require 'local_svn'

module LiveModeTestCase

  def setup
    super
    @repo = self.create_repository
    @config = Configuration.new(self.repo_type)
    @config.repo = @repo.url
    @config.go_live
    do_setup
  end

  def create_repository
    LocalSubversionRepository.new
  end
  
  def repo_type
    'subversion'
  end

  def do_setup; end
    
  def teardown
    super
    @repo.destroy
    @config.revert
    do_teardown
  end

  def do_teardown; end

end
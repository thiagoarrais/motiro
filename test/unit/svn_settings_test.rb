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

require 'stringio'

require 'reporters/svn_settings'

EXPECTED_FILE_NAME = File.expand_path(File.dirname(__FILE__) +
                       '../../../config/motiro.yml')

class SubversionSettingsProviderTest < Test::Unit::TestCase
  
  def setup
    @opener = FlexMock.new 
    
    @opener.should_receive(:open).with(EXPECTED_FILE_NAME).
      zero_or_more_times.
      returns do
        StringIO.new( "package_size: 8\n" +
                      "update_interval: 10\n" +
                      "subversion:\n" +
                      "  repo: svn://svn.berlios.de/motiro\n")
      end
    
    @provider = SubversionSettingsProvider.new(@opener)
  end
  
  def test_fetches_repo_url
    assert_equal 'svn://svn.berlios.de/motiro', @provider.repo_url
  end
  
  def test_returns_nil_when_credentials_not_specified
    assert_nil @provider.repo_user
    assert_nil @provider.repo_password  
  end
  
  def teardown
    @opener.mock_verify
  end
    
  #TODO ill-formed yaml
  #TODO one or more options not present in the file
  #TODO file does not exist
  #TODO somebody messed the config file and placed a non-number on package_size
    
end

class SubversionSettingsProviderAuthenticatedTest < Test::Unit::TestCase

  def test_fetches_credentials
    FlexMock.use do |opener|
      opener.should_receive(:open).with(EXPECTED_FILE_NAME).
        zero_or_more_times.
        returns do
          StringIO.new( "package_size: 8\n" +
                        "update_interval: 10\n" +
                        "subversion:\n" +
                        "  repo: svn://svn.berlios.de/motiro\n" +
                        "  user: eddie\n" +
                        "  password: vedder\n")
        end

      provider = SubversionSettingsProvider.new(opener)

      assert_equal 'eddie', provider.repo_user
      assert_equal 'vedder', provider.repo_password
    end  
  end

end
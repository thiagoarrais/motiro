require File.dirname(__FILE__) + '/../test_helper'

require 'stringio'

require 'mocks/filesystem'
require 'reporters/svn_settings'

class SubversionSettingsProviderTest < Test::Unit::TestCase

    def setup
        expected_file_name = File.expand_path(File.dirname(__FILE__) +
                             '../../../config/report/subversion.yml')
        @opener = MockFileSystem.new
        @opener.expect_open(expected_file_name) do
            StringIO.new( "repo: svn://svn.berlios.de/motiro\n" +
                          "package_size: 8")
        end
        @provider = SubversionSettingsProvider.new(@opener)
    end

    def test_fetches_repo_url
        assert_equal 'svn://svn.berlios.de/motiro', @provider.getRepoURL
        @opener.verify
    end
    
    def test_fetches_package_size
        assert_equal 8, @provider.getPackageSize
        @opener.verify
    end
    
    #TODO mal-formed yaml
    #TODO one or more options not present in the file
    #TODO file does not exist
    #TODO somebody messed the config file and placed a non-number on package_size

end
require File.dirname(__FILE__) + '/../test_helper'

require 'stringio'

require 'reporters/svn_settings'

class SubversionSettingsProviderTest < Test::Unit::TestCase

    def setup
        expected_file_name = File.expand_path(File.dirname(__FILE__) +
                             '../../../config/motiro.yml')
        @opener = FlexMock.new 
        
        @opener.should_receive(:open).with(expected_file_name).
          once.
          returns( StringIO.new( "package_size: 8\n" +
                                 "update_interval: 10\n" +
                                 "svn:\n" +
                                 "  repo: svn://svn.berlios.de/motiro\n"))

        @provider = SubversionSettingsProvider.new(@opener)
    end

    def test_fetches_repo_url
        assert_equal 'svn://svn.berlios.de/motiro', @provider.repo_url
    end
    
    def teardown
        @opener.mock_verify
    end
    
    #TODO mal-formed yaml
    #TODO one or more options not present in the file
    #TODO file does not exist
    #TODO somebody messed the config file and placed a non-number on package_size

end
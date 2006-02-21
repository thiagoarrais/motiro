require File.expand_path(File.dirname(__FILE__) + '/../test_env')

require 'reporters/svn_settings'

class SubversionSettingsProviderTest < Test::Unit::TestCase

    def test_open_file
        opener = MockFileSystem.new
        opener.expect_open(File.expand_path(File.dirname(__FILE__) + '../../config/report/subversion.yml'))
        opener.return_open('svn://svn.berlios.de/motiro')
        
        provider = SubversionSettingsProvider.new(opener)
        
        url = opener.getRepoURL
        
        assert_equal 'svn://svn.berlios.de/motiro', url
        opener.verify
    end

end
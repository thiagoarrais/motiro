require File.expand_path(File.dirname(__FILE__) + '/../test_env')

require 'stringio'

require 'mocks/filesystem'
require 'reporters/svn_settings'

class SubversionSettingsProviderTest < Test::Unit::TestCase

    def test_open_file
        opener = MockFileSystem.new
        opener.expect_open( File.expand_path(File.dirname(__FILE__) +
                            '../../../config/report/subversion.yml')) do
                              StringIO.new "repo: svn://svn.berlios.de/motiro\n"
                          end
        
        provider = SubversionSettingsProvider.new(opener)
        
        url = provider.getRepoURL
        
        assert_equal 'svn://svn.berlios.de/motiro', url
        opener.verify
    end

end
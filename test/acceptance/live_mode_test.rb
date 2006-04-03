require 'configuration'
require 'local_svn'

module LiveModeTestCase

    def setup
        super
        @repo = LocalSubversionRepository.new
        @config = Configuration.new
        @config.repo = @repo.url
        @config.go_live
        do_setup
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
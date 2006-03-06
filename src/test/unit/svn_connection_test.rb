require File.dirname(__FILE__) + '/../test_helper'

require 'test/unit'

require 'reporters/svn_connection'

require 'stubs/svn_settings'
require 'mocks/runner'

class SubversionConnectionTest < Test::Unit::TestCase

    def test_connection
        settings = StubConnectionSettingsProvider.new('svn://svn.berlios.de/motiro')
        runner = MockRunner.new
        connection = SubversionConnection.new(settings, runner)
        
        runner.expect_run 'svn log svn://svn.berlios.de/motiro'

        connection.log
        
        runner.verify
    end
    
end
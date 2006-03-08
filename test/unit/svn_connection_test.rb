require File.dirname(__FILE__) + '/../test_helper'

require 'test/unit'

require 'reporters/svn_connection'

require 'stubs/svn_settings'
require 'mocks/runner'

class SubversionConnectionTest < Test::Unit::TestCase

    def test_connection
        settings = StubConnectionSettingsProvider.new(
                       :repo => 'svn://svn.berlios.de/motiro')

        runner = MockRunner.new
        connection = SubversionConnection.new(settings, runner)
        
        runner.expect_run 'svn log --limit=5 svn://svn.berlios.de/motiro'

        connection.log
        
        runner.verify
    end
    
    def test_limit_query_size
        
        settings = StubConnectionSettingsProvider.new(
                       :package_size => 3)
                       
        runner = MockRunner.new
        connection = SubversionConnection.new(settings, runner)
        
        runner.expect_run 'svn log --limit=3 http://svn.fake.domain.org/fake_repo'
        
        connection.log
        
        runner.verify
    end
    
end
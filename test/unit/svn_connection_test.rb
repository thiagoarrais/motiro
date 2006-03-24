require File.dirname(__FILE__) + '/../test_helper'

require 'rubygems'
require 'flexmock'

require 'test/unit'

require 'reporters/svn_connection'

require 'stubs/svn_settings'
require 'mocks/runner'

class SubversionConnectionTest < Test::Unit::TestCase

    def test_reads_repo_url
        settings = StubConnectionSettingsProvider.new(
                       :repo => 'svn://svn.berlios.de/motiro')

        runner = MockRunner.new
        connection = SubversionConnection.new(settings, runner)
        
        runner.expect_run 'svn log svn://svn.berlios.de/motiro -v --limit=5'

        connection.log
        
        runner.verify
    end
    
    def test_limit_query_size
        
        settings = StubConnectionSettingsProvider.new(
                       :package_size => 3)
                       
        runner = MockRunner.new
        connection = SubversionConnection.new(settings, runner)
        
        runner.expect_run 'svn log http://svn.fake.domain.org/fake_repo -v --limit=3'
        
        connection.log
        
        runner.verify
    end
    
    def test_limit_to_one_revision
        FlexMock.use do |runner|
            settings = StubConnectionSettingsProvider.new

            runner.should_receive(:run).
                with('svn log http://svn.fake.domain.org/fake_repo -v -r7')
                
            connection = SubversionConnection.new(settings, runner)
            
            connection.log(7)
        end
    end
    
    # TODO what happens if we ask for an inexistent revision
    
end
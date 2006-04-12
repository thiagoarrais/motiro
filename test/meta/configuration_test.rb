require File.dirname(__FILE__) + '/../test_helper'

require 'configuration'
require 'yaml'

class ConfigurationTest < Test::Unit::TestCase
    
    FILE_NAME = File.dirname(__FILE__) + '/../../config/motiro.yml'

    def setup
        @config = Configuration.new
    end

    def test_reconfigure_update_interval
        expected_interval = 6
        @config.update_interval = expected_interval
        assert_equal expected_interval, read('update_interval')
    end
    
    def test_revert
        original_contents = File.open(FILE_NAME).read

        @config.update_interval = 13
        @config.revert
        
        assert_equal original_contents, File.open(FILE_NAME).read
    end

    def test_switch_to_live_mode
        @config.go_live
        assert_equal 0, read('update_interval')
    end

    def test_switch_to_cached_mode
        @config.go_cached
        assert_equal 10, read('update_interval')
    end
    
    def test_reconfigure_repo_url
        expected_url = 'http://www.nowhere.com'
        @config.repo = expected_url
        assert_equal expected_url, read('svn/repo')
    end

    def teardown
        @config.revert
    end

private

    def read(key)    
        file = File.open(FILE_NAME)
        configs = YAML.load(file)
        file.close

        result = configs
        key.split('/').each do |node|
            result = result[node]
        end
        return result
    end

end
require File.dirname(__FILE__) + '/../test_helper'

require 'local_svn'

class LocalSubversionRepositoryTest < Test::Unit::TestCase
    
    def test_readable_to_anonymous
        repo = LocalSubversionRepository.new
        
        pio = IO.popen("svn ls #{repo.url} 2>&1")
        assert_equal '', pio.read # no error message
        
        repo.destroy
    end
    
    def test_create_and_destroy
        repo = LocalSubversionRepository.new
        
        repo.destroy
        
        pio = IO.popen("svn ls #{repo.url} 2>&1")
        assert '' != pio.read # some error message
    end
    
end
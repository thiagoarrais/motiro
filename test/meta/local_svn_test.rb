require File.dirname(__FILE__) + '/../test_helper'

require 'local_svn'

class LocalSubversionRepositoryTest < Test::Unit::TestCase
    
    def setup
        @repo = LocalSubversionRepository.new
    end

    def test_readable_to_anonymous
        pio = IO.popen("svn ls #{@repo.url} 2>&1")
        assert_equal '', pio.read # no error message
    end
    
    def test_create_and_destroy
        @repo.destroy
        
        pio = IO.popen("svn ls #{@repo.url} 2>&1")
        assert '' != pio.read # some error message
    end
    
    def test_make_remote_dir
        @repo.mkdir('testdir', 'directory for tests created')

        pio = IO.popen("svn ls #{@repo.url} 2>&1")
        assert "testdir/\n" == pio.read # some error message
    end
    
    def test_make_local_dir
        @repo.mkdir('not_yet_commited_dir')
        
        pio = IO.popen("svn ls #{@repo.url} 2>&1")
        assert '' == pio.read
        
        @repo.commit('created a new dir')
        
        pio = IO.popen("svn ls #{@repo.url} 2>&1")
        assert "not_yet_commited_dir/\n" == pio.read # some error message
    end
    
    def teardown
        @repo.destroy
    end
    
end
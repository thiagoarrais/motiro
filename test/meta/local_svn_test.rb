require File.dirname(__FILE__) + '/../test_helper'

require 'local_svn'

class LocalSubversionRepositoryTest < Test::Unit::TestCase
    
    def setup
        @repo = LocalSubversionRepository.new
    end

    def test_readable_to_anonymous
        assert_equal '', execute("svn ls #{@repo.url}") # no error message
    end
    
    def test_create_and_destroy
        @repo.destroy
        
        assert '' != execute("svn ls #{@repo.url}") # some error message
    end
    
    def test_make_remote_dir
        @repo.mkdir('testdir', 'directory for tests created')

        assert "testdir/\n" == execute("svn ls #{@repo.url}")
    end
    
    def test_make_local_dir
        @repo.mkdir('not_yet_commited_dir')
        
        assert '' == execute("svn ls #{@repo.url}")
        
        @repo.commit('created a new dir')
        
        assert_equal "not_yet_commited_dir/\n", execute("svn ls #{@repo.url}")
    end
    
    def test_add_file
        @repo.add_file('local_file.txt', "the file is stored locally until\n" +
                                         "I choose to commit it")

        assert '' == execute("svn ls #{@repo.url}")
        
        @repo.commit('added a file')
        
        assert_equal "local_file.txt\n", execute("svn ls #{@repo.url}")
    end
    
    def teardown
        @repo.destroy
    end
    
private

    def execute(command_line)
        pio = IO.popen("#{command_line} 2>&1")
        return pio.read
    end
    
end
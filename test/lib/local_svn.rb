require 'fileutils'
require 'socket'

include FileUtils

class LocalSubversionRepository

    attr_reader :url

    def initialize
        @username = 'motiro'
        @password = 'motiro-pass'

        repo_dir = create_repo
        authorize_anon_read(repo_dir, @username, @password)
        @url = start_server(repo_dir)
    end
    
    def destroy
        kill_server
        rm_rf(@svn_dir)
    end

private
    def create_repo
        tmpdir = ENV['TEMP']
        @svn_dir =  find_free_dir_under tmpdir
        repo_dir =  "#{@svn_dir}/repo"

        mkdir_p(repo_dir) 

        `svnadmin create #{repo_dir}`
        
        return repo_dir
    end
    
    def find_free_dir_under(parent_dir)
        contents = Dir.entries(parent_dir)
        prefix = 'svn'
        suffix = ''
        if (contents.include?(prefix))
            suffix = 1
            while(contents.include?(prefix + suffix.to_s))
                suffix += 1
            end
        end
        
        return parent_dir + '/' + prefix + suffix.to_s
    end

    def start_server(repo_dir)
        port = find_available_port

        @server_pid = fork do
            exec "svnserve -d --foreground --listen-port #{port} -r #{repo_dir}"
        end
        
        sleep 0.4 # give some time for the server to boot
        
        return "svn://localhost:#{port}"
    end
    
    def kill_server
        Process.kill('SIGKILL', @server_pid)
    end
    
    def authorize_anon_read(repo_dir, username, password)
        svnserve_file = File.open(repo_dir + '/conf/svnserve.conf', 'w')
        svnserve_file << "[general]\n" <<
                         "anon-access = read\n" <<
                         "auth-acces = write\n" <<
                         "password-db = passwd\n"
        svnserve_file.close
        
        passwd_file = File.open(repo_dir + '/conf/passwd', 'w')
        passwd_file << "[users]\n" <<
                       "#{username} = #{password}\n"
        passwd_file.close
    end
    
    def find_available_port
        port = 36906
        while(try_port(port))
            port += 1
        end
        
        return port
    end
    
    def try_port(port)
        begin
            t = TCPSocket.new('localhost', port)
            t.close
            return true
        rescue
            return false
        end
    end

end
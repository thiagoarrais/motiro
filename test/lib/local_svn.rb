require 'fileutils'
require 'socket'

include FileUtils

class LocalSubversionRepository

    attr_reader :url
    attr_reader :wc_dir

    def initialize
        @username = 'motiro'
        @password = 'motiro-pass'

        @root_dir = find_root_dir
        repo_dir = create_repo(@root_dir)
        authorize_anon_read(repo_dir, @username, @password)
        @url = start_server(repo_dir)
        @wc_dir = create_working_copy(@root_dir, @url)        
        @valid = true
    end
    
    def destroy
        if @valid
            @valid = false
            kill_server
            rm_rf(@root_dir)
        end
    end
    
    def mkdir(dirname, comment=nil)
        if comment.nil? then
            svn_command("mkdir #{self.wc_dir}/#{dirname}")
        else
            svn_command("mkdir #{self.url}/#{dirname}", comment)
        end
    end
    
    def commit(comment)
        svn_command("commit #{self.wc_dir}", comment)
    end

private

    def svn_command(command, comment=nil)
        line = "svn #{command} --username #{@username} --password #{@password}"
        line += " -m '#{comment}'" unless comment.nil?
        line += " > /dev/null 2>&1"
        system(line)
    end

    def create_repo(root_dir)
        repo_dir =  "#{root_dir}/repo"

        mkdir_p(repo_dir) 

        `svnadmin create #{repo_dir}`
        
        return repo_dir
    end
    
    def create_working_copy(root_dir, repo_url)
       wc_dir = find_free_dir_under(root_dir, 'wc')
       svn_command("checkout #{repo_url} #{wc_dir}")
       return wc_dir
    end
    
    def find_root_dir
        tmpdir = ENV['TEMP']
        return find_free_dir_under(tmpdir, 'svn')
    end

    def find_free_dir_under(parent_dir, prefix)
        contents = Dir.entries(parent_dir)
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
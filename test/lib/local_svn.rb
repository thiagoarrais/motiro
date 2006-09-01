require 'fileutils'

require 'repoutils'

include FileUtils

class LocalSubversionRepository
  
  attr_reader :url
  attr_reader :wc_dir
  attr_reader :username
  
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
  
  def add_file(filename, contents)
    put_file(filename, contents)
  end
  
  def put_file(filename, contents)
    absolute_file = "#{self.wc_dir}/#{filename}"
    existed = FileTest.exists? absolute_file
    
    file = File.open(absolute_file, 'w')
    file << contents
    file.close
    if !existed
      svn_command("add #{absolute_file}")
    end
  end
  
  def commit(comment)
    svn_command("commit #{self.wc_dir}", comment)
  end
  
  def copy(src, dest, comment)
    svn_command("copy #{self.url}/#{src} #{self.url}/#{dest}", comment)
  end
  
  def move(src, dest, comment)
    svn_command("move #{self.url}/#{src} #{self.url}/#{dest}", comment)
  end
  
  private
  
  include RepoUtils
  
  def svn_command(command, comment=nil)
    line = "svn #{command}"
    unless comment.nil?
      line += " --username #{@username} --password #{@password} -m \"#{comment}\""
    end
    `#{line}`
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
  
  def start_server(repo_dir)
    port = find_available_port
    
    @server_pid = start_process(
      "svnserve -d --foreground --listen-port #{port} -r #{repo_dir}")
    
    sleep 0.5 # give some time for the server to boot
    
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
  
  @@fork_ok = true

  def start_process(cmd)
  # function inspired by Kirk Haines' code, published on ruby-talk group
  # original code available at
  # http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/211793
    begin
      raise NotImplementedError unless @@fork_ok
      pid = fork do
        exec(cmd)
      end
    rescue NotImplementedError
      @@fork_ok = false
      begin
        require 'rubygems'
      rescue Exception
      end
      
      begin
        require 'win32/process'
      rescue LoadError
        raise "Please install win32-process.\n'gem install win32-process' or http://rubyforge.org/projects/win32utils"
      end
      
      pid = Process.create(:app_name => cmd).process_id
      
    end
    
    return pid
  end

end
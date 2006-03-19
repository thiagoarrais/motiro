require File.dirname(__FILE__) + "/../../vendor/selenium/seletest"

require 'fileutils'

include FileUtils

class SubversionAcceptanceTest < Test::Unit::TestCase

    def setup
        super
        @app_root = File.expand_path(File.dirname(__FILE__) + '/../..')
        @svn_path =  File.expand_path(File.dirname(__FILE__) + "/../svn")
        @repo_path =  "#{@svn_path}/repo"
        @username = 'motiro'
        @password = 'motiro-pass'
        
        @repo_url = start_server
        switch_to_development_mode
    end


    def test_short_headline
        commit_msg = 'Created my project'
        `svn mkdir --username #{@username} --password #{@password} #{@repo_url}/myproject -m '#{commit_msg}'`

        open '/report/subversion'
        assertTextPresent @username
        assertTextPresent commit_msg
        clickAndWait "//img[@src='/images/rss.gif']"
        assertText "//rss/channel/item/title", commit_msg
        assertText "//rss/channel/item/author", @username
    end
    
    def teardown
        super
        kill_server
        switch_back_to_normal_mode
    end
    
private
    def start_server
        port = 36906        
        
        mkdir_p(@repo_path) 
        `svnadmin create #{@repo_path}`
        
        conf_file = File.open("#{@repo_path}/conf/svnserve.conf", 'w')
        conf_file << "[general]\n" <<
                     "anon-access = read\n" <<
                     "auth-acces = write\n" <<
                     "password-db = passwd\n"
        conf_file.close
        
        passwd_file = File.open("#{@repo_path}/conf/passwd", 'w')
        passwd_file << "[users]\n" <<
                       "#{@username} = #{@password}\n"
                       
        passwd_file.close
        
        @server_pid = fork do
            exec "svnserve -d --foreground --listen-port #{port} -r #{@repo_path}"
        end
        
        sleep 1
        
        return "svn://localhost:#{port}"
    end
    
    def kill_server
        Process.kill('SIGTERM', @server_pid)
        rm_rf("#{@svn_path}")
    end
    
    def switch_to_development_mode
        cp("#{@app_root}/config/report/subversion.yml", "#{@app_root}/config/report/subversion.yml.bak")
        config_file = File.open("#{@app_root}/config/report/subversion.yml", 'w')
        config_file << "repo: #{@repo_url}/myproject\n" <<
                       "update_interval: 0\n" <<
                       "package_size: 5\n"
        config_file.close
    end
    
    def switch_back_to_normal_mode
        cp("#{@app_root}/config/report/subversion.yml.bak", "#{@app_root}/config/report/subversion.yml")
        rm_f("#{@app_root}/config/report/subversion.yml.bak")
    end

end
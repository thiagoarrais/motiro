require 'fileutils'

include FileUtils

class MotiroAcceptanceTest < Test::Unit::TestCase

    def test_no_error_on_development_mode
    
        switch_to_development_mode
        
        open '/report/events'
        assertTextPresent 'Próximos eventos'
        
        switch_back_to_normal_mode
        
    end

# TODO  All those private methods were copied from subversion_test.rb
#       Move them to a separate class
private

    def switch_to_development_mode
        cp("#{app_root}/config/report/subversion.yml", "#{app_root}/config/report/subversion.yml.bak")
        config_file = File.open("#{app_root}/config/report/subversion.yml", 'w')
        config_file << "repo: http://svn.berlios.de/svnroot/repos/motiro\n" <<
                       "update_interval: 0\n" <<
                       "package_size: 5\n"
        config_file.close
    end
    
    def switch_back_to_normal_mode
        cp("#{app_root}/config/report/subversion.yml.bak", "#{app_root}/config/report/subversion.yml")
        rm_f("#{app_root}/config/report/subversion.yml.bak")
    end
    
    def app_root
        return File.expand_path(File.dirname(__FILE__) + '/../..')
    end

end
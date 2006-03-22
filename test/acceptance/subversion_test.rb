require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + "/../../vendor/selenium/seletest"

require 'fileutils'

require 'local_svn'

include FileUtils

class SubversionAcceptanceTest < Test::Unit::TestCase

    def setup
        super
        @repo = LocalSubversionRepository.new
        switch_to_development_mode
    end


    def test_short_headline
        commit_msg = 'Created my project'
        
        @repo.mkdir('myproject', commit_msg)
        
        open '/report/subversion'
        assertTextPresent @username
        assertTextPresent commit_msg
        clickAndWait "//img[@src='/images/rss.gif']"
        assertText "//rss/channel/item/title", commit_msg
        assertText "//rss/channel/item/author", @repo.username
    end
    
    def test_show_subversion_on_main_page_when_in_development_mode
        commit_msg = 'Created another project'

        @repo.mkdir('myproject', commit_msg)
        
        open '/'
        assertTextPresent 'Últimas notícias do Subversion'
        assertTextPresent commit_msg
    end
    
    def test_report_rss
        commit_title = 'Created my project'
        commit_msg = "#{commit_title}\n" +
                     "\n"
                     "This revision creates a brand new directory where we \n" +
                     "will keep or project files"
        
        @repo.mkdir('myproject', commit_msg)

        open('/feed/subversion')
        assertText('//rss/channel/title', 'Motiro - Subversion')
        assertElementPresent '//rss/channel/description'
        assertText '//rss/channel/generator', 'Motiro'
        assertText '//rss/channel/item/title', commit_title
        assertText('//rss/channel/item/description', commit_msg)
    end
    
    def teardown
        super
        @repo.destroy
        switch_back_to_normal_mode
    end
    
private

    def switch_to_development_mode
        cp("#{app_root}/config/report/subversion.yml", "#{app_root}/config/report/subversion.yml.bak")
        config_file = File.open("#{app_root}/config/report/subversion.yml", 'w')
        config_file << "repo: #{@repo.url}/myproject\n" <<
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
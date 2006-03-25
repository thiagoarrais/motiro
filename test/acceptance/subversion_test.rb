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
        
        storeText "//rss/channel/item/link", 'link'
        open '${link}'
        assert_title 'Motiro - Subversion - Revisão r1'
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
        assertText '//rss/channel/generator', 'Motiro'
        assertText '//rss/channel/item/title', commit_title
        assertText('//rss/channel/item/description', "regexp:#{commit_msg}")
    end
    
    def test_records_revision_description
        commit_title = 'I have created the project dir'
        commit_msg = "#{commit_title}\n" +
                     "\n"
                     "This project dir will hold everything needed to build and\n" +
                     "deploy our project from source code"
        dir_name = 'myproject'
        
        @repo.mkdir(dir_name, commit_msg)

        open '/report/subversion'
        assertTextPresent commit_title
        clickAndWait "//a[text() = \"#{commit_title}\"]"

        assertTitle "Motiro - Subversion - Revisão r1"
        assertElementPresent "//h1[text() = 'Revisão r1']"
        assertElementPresent "//div[@id='description']"
        assertTextPresent commit_msg
        
        assertElementPresent "//div[@id='summary']"
        assertTextPresent "A /#{dir_name}"
        
        # TODO assert that details of adding a file is showing the file contents
        # TODO assert that details of altering a file shows the diff output
    end
    
    def test_showing_invalid_rid_shows_nice_error_message
        commit_msg = 'Creating the project root'
        
        @repo.mkdir('projectroot', commit_msg)
        
        open '/report/show/r104?reporter=subversion'
        assertTitle "Motiro: Bem-vindo"
        assertText "//div[@id='notice']", "Não foi possível encontrar o artigo r104 do repórter Subversion"
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
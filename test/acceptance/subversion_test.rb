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
    end
    
    def test_shows_diff_output_when_adding_file
        commit_title = 'I have added a file'
        filename = 'a_file.txt'
        file_contents = "These are the file contents\n"
        diff_output = "@@ -0,0 +1 @@\n" +
                      "+#{file_contents}"

        @repo.add_file(filename, file_contents)
        @repo.commit(commit_title)
        
        open '/report/subversion'
        clickAndWait "//a[text() = '#{commit_title}']"

        assertElementPresent "//a[text()='A /#{filename}']"
        assertElementPresent "//h2[text()='Alterações em a_file.txt']"
        assertTextPresent diff_output
    end
    
    def test_shows_diff_output_when_modifying_file
        test_shows_diff_output_when_adding_file
        diff_output = "@@ -1 +1 @@\n" +
                      "-These are the file contents\n" +
                      "+These are the modified file contents\n"
        
        commit_title = 'I have modified a file'
        @repo.put_file('a_file.txt', "These are the modified file contents\n" )
        @repo.commit(commit_title)
        
        open '/report/subversion'
        clickAndWait "//a[text() = '#{commit_title}']"

        assertTextPresent diff_output
    end
    
    def test_showing_invalid_rid_shows_nice_error_message
        commit_msg = 'Creating the project root'
        
        @repo.mkdir('projectroot', commit_msg)
        
        open '/report/show/r104?reporter=subversion'
        assertTitle "Motiro: Bem-vindo"
        assertText "//div[@id='notice']", "Não foi possível encontrar o artigo r104 do repórter Subversion"
    end
    
    def test_do_not_show_diff_section_when_adding_directories
        commit_title = 'Creating the projecto trunk'        
        
        @repo.mkdir('trunk', commit_title)
        
        open '/report/subversion'
        clickAndWait "//a[text() = '#{commit_title}']"
        
        assertElementNotPresent "//a"
        assertTextNotPresent "Alterações em trunk"
        
    end
    
    # TODO what should be the behaviour when removing files?
    # TODO on recorded mode, when something bad happens (like a connection
    #      timeout) during headline retrieval, the headlines are carved in
    #      stone that way and can't be fixed
    
    # TODO  copy and move files around
    #       there seems to be a bug when copying files the diff summary looks
    #       like this:  A /trunk/app/views/report/html_fragment.rhtml (from /trunk/app/views/report/subversion_html_fragment.rhtml:123)
    #       and the change title will be something like 'Changes in subversion_html_fragment.rhtml:123)'
    #       also the diff maybe incorrectly placed
    #       see motiro's revision r124
    
    def teardown
        super
        @repo.destroy
        switch_back_to_normal_mode
    end
    
private

    def switch_to_development_mode
        cp("#{app_root}/config/report/subversion.yml", "#{app_root}/config/report/subversion.yml.bak")
        config_file = File.open("#{app_root}/config/report/subversion.yml", 'w')
        config_file << "repo: #{@repo.url}\n" <<
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
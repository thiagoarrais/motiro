require 'acceptance/live_mode_test'

class SubversionAcceptanceTest < Test::Unit::TestCase

    include LiveModeTestCase

    def test_short_headline
        commit_msg = 'Created my project'
        
        @repo.mkdir('myproject', commit_msg)
        
        open '/report/subversion'
        assertTextPresent @username
        assertTextPresent commit_msg
        clickAndWait "//img[starts-with(@src, '/images/rss.gif')]"
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
    
    def test_copy_file
        @repo.add_file('file_number_one.txt', "the content here will be copied to file_number_two\n")
        @repo.commit('added first file')
        
        commit_title = 'files copied'
        @repo.copy('file_number_one.txt', 'file_number_two.txt', commit_title)
        
        open '/report/subversion'
        clickAndWait "//a[text() = '#{commit_title}']"
        assertTextPresent "Alterações em file_number_two.txt"
        assertTextPresent "@@ -0,0 +1 @@\n+the content here will be copied to file_number_two"
    end
    
    def test_move_file
        @repo.add_file('file_number_one.txt', "this file will be renamed to file_number_two\n")
        @repo.commit('added first file')
        
        commit_title = 'renamed file'
        @repo.move('file_number_one.txt', 'file_number_two.txt', commit_title)
        
        open '/report/subversion'
        clickAndWait "//a[text() = '#{commit_title}']"

        assertTextPresent "Alterações em file_number_one.txt"
        assertTextPresent "@@ -1 +0,0 @@\n-this file will be renamed to file_number_two"
        assertTextPresent "Alterações em file_number_two.txt"
        assertTextPresent "@@ -0,0 +1 @@\n+this file will be renamed to file_number_two"
    end

end
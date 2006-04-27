require 'acceptance/live_mode_test'

class SubversionAcceptanceTest < SeleniumTestCase

    include LiveModeTestCase
    
    def test_short_headline
        commit_msg = 'Created my project'
        
        @repo.mkdir('myproject', commit_msg)
        
        open '/report/subversion'
        assert_text_present @username
        assert_text_present commit_msg
        click "//img[starts-with(@src, '/images/rss.gif')]"
        wait_for_page_to_load(1000)
        assert_equal commit_msg, get_text("//rss/channel/item/title")
        assert_equal @repo.username, get_text("//rss/channel/item/author")
        
        link = get_text("//rss/channel/item/link")
        open link
        #FIXME assert_equal 'Motiro - Subversion - Revisão r1', get_title
        assert get_title.match(/Motiro - Subversion - Revis/)
        assert get_title.match(/o r1/)
    end
    
    def test_show_subversion_on_main_page_when_in_development_mode
        commit_msg = 'Created another project'

        @repo.mkdir('myproject', commit_msg)
        
        open '/'
        #FIXME assert_text_present 'Últimas notícias do Subversion'
        assert_text_present 'cias do Subversion'
        assert_text_present commit_msg
    end
    
    def test_report_rss
        commit_title = 'Created my project'
        commit_msg = "#{commit_title}\n" +
                     "\n" +
                     "This revision creates a brand new directory where we \n" +
                     "will keep our project files"
        
        @repo.mkdir('myproject', commit_msg)

        open('/feed/subversion')
        assert_text('//rss/channel/title', 'Motiro - Subversion')
        assert_text '//rss/channel/generator', 'Motiro'
        assert_text '//rss/channel/item/title', commit_title
        assert_text('//rss/channel/item/description', /#{commit_msg.delete("\n")}/)
    end
    
    def test_records_revision_description
        commit_title = 'I have created the project dir'
        commit_msg = "#{commit_title}\n" +
                     "\n" +
                     "This project dir will hold everything needed to build and\n" +
                     "deploy our project from source code"
        dir_name = 'myproject'
        
        @repo.mkdir(dir_name, commit_msg)

        open '/report/subversion'
        assert_text_present commit_title
        click "//a[text() = \"#{commit_title}\"]"
        wait_for_page_to_load(1000)

        #FIXME assert_equal "Motiro - Subversion - Revisão r1", get_title
        assert /Motiro - Subversion - Revis/.match(get_title)
        assert /o r1\z/.match(get_title)
        #FIXME ADD: assert_element_present "//h1[text() = 'Revisão r1']"
        assert_element_present "//div[@id='description']"
        assert_text_present commit_msg
        
        assert_element_present "//div[@id='summary']"
        assert_text_present "A /#{dir_name}"
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
        click "//a[text() = '#{commit_title}']"
        wait_for_page_to_load(1000)

        assert_element_present "//a[text()='A /#{filename}']"
        #FIXME ADD: assert_element_present "//h2[text()='Alterações em a_file.txt']"
        assert_text_present diff_output
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
        click "//a[text() = '#{commit_title}']"
        wait_for_page_to_load(1000)

        assert_text_present diff_output
    end
    
    def test_showing_invalid_rid_shows_nice_error_message
        commit_msg = 'Creating the project root'
        
        @repo.mkdir('projectroot', commit_msg)
        
        open '/report/show/r104?reporter=subversion'
        assert_equal "Motiro: Bem-vindo", get_title
        #FIXME assertText "//div[@id='notice']", "Não foi possível encontrar o artigo r104 do repórter Subversion"
        assert_text "//div[@id='notice']", /vel encontrar o artigo r104 do rep/
    end
    
    def test_do_not_show_diff_section_when_adding_directories
        commit_title = 'Creating the projecto trunk'        
        
        @repo.mkdir('trunk', commit_title)
        
        open '/report/subversion'
        click "//a[text() = '#{commit_title}']"
        wait_for_page_to_load(1000)
        
        assert_element_not_present "//a"
        #FIXME assert_text_not_present "Alterações em trunk"
        assert_text_not_present "es em trunk"
        
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
        click "//a[text() = '#{commit_title}']"
        wait_for_page_to_load(1000)
        #FIXME assert_text_present "Alterações em file_number_two.txt"
        assert_text_present "es em file_number_two.txt"
        assert_text_present "@@ -0,0 +1 @@\n+the content here will be copied to file_number_two"
    end
    
    def test_move_file
        @repo.add_file('file_number_one.txt', "this file will be renamed to file_number_two\n")
        @repo.commit('added first file')
        
        commit_title = 'renamed file'
        @repo.move('file_number_one.txt', 'file_number_two.txt', commit_title)
        
        open '/report/subversion'
        click "//a[text() = '#{commit_title}']"
        wait_for_page_to_load(1000)

        #FIXME assert_text_present "AlteraÃ§Ãµes em file_number_one.txt"
        assert_text_present "es em file_number_one.txt"
        assert_text_present "@@ -1 +0,0 @@\n-this file will be renamed to file_number_two"
        #FIXME assert_text_present "AlteraÃ§Ãµes em file_number_two.txt"
        assert_text_present "es em file_number_two.txt"
        assert_text_present "@@ -0,0 +1 @@\n+this file will be renamed to file_number_two"
    end
    
end

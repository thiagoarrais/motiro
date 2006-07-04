class MainPageAcceptanceTest < SeleniumTestCase

    fixtures :users
    
    def test_version_number
        open '/'
        assert_text_present '0.4'
    end
        
    def test_report_html
        open '/report/subversion?locale=en'
        assert_text_present 'Latest news from Subversion'
        click "//img[starts-with(@src, '/images/rss.png')]"
        wait_for_page_to_load(500)
        assert_location 'exact:http://localhost:3000/feed/subversion'
    end
    
    def test_subversion_on_main
        open('/en')
        assert_element_present "//div[@id = 'svn']"
        assert get_text("//div[@id = 'svn']").match(/Latest news from Subversion/)
    end
    
    def test_events_on_main
        open('/en')
        assert_element_present "//div[@id = 'events']"
        assert get_text("//div[@id = 'events']").match(/Upcoming events/)
    end
    
    def test_edition_disabled_without_authentication
        open('/en')
        assert_element_present "//span[@class = 'disabled']"
        assert_equal "Edit (requires authentication)",
                     get_text("//span[@class = 'disabled']")
    end
    
    def test_welcomes_user
        open('/en')
        type 'user_login', 'bob'
        type 'user_password', 'test'
        
        click 'login'
        wait_for_page_to_load(1000)
        
        assert_text_present 'Welcome, bob'
    end

    def test_edition_enabled_when_authenticated
        #TODO refactor this to a declarative style
        #see http://www.testing.com/cgi-bin/blog/2005/12/19
        open('/')
        type 'user_login', 'bob'
        type 'user_password', 'test'
        
        click 'login'
        wait_for_page_to_load(1000)
        
        assert_location 'exact:http://localhost:3000/'
        
        assert_element_present "//a[text() = 'Editar']"
        click "//a[text() = 'Editar']"
        
        wait_for_page_to_load(1000)

        assert_element_present "//input[@name='btnSave']"
        assert_element_present "//input[@name='btnCancel']"
        assert_element_present "//textarea[@id='txaEditor']"
    end
    
    def test_edit_main_page
        open('/en')
        type 'user_login', 'bob'
        type 'user_password', 'test'
        
        click 'login'
        wait_for_page_to_load(1000)
        
        click "//a[text() = 'Edit']"
        wait_for_page_to_load(1000)
        
        type 'txaEditor', "= Motiro =\n\nThis is project motiro."
        click 'btnSave'
        
        wait_for_page_to_load(1000)
        
        assert_equal 'Motiro', get_text('//h1')
        assert_text_present 'This is project motiro'
    end
    
    def test_shows_installation_sucessful_page_with_absent_main_page
        open('/en')
        assert_text_present 'Congratulations! Motiro was installed correctly'
    end
    
    def test_switches_languages_when_not_logged_in
        open('/')
        click "//a[@id='pt-BR']"
        wait_for_page_to_load(1000)
        
        assert_equal "Motiro: Bem-vindo", get_title
        assert_text_present 'Usu' # TODO Usuário
        assert_text_present 'Senha'
        assert_text_present 'instalou o Motiro corretamente'
        assert_text_present 'Editar (identifique-se, por favor)'
        assert_text_present 'ximos eventos'
        assert_text_present 'ltimas not' # TODO Últimas notícias do Subversion
        assert_text_present 'cias do Subversion'
        assert_text_present 'Motiro vers'

        click "//a[@id='en']"
        wait_for_page_to_load(1000)

        assert_equal "Motiro: Welcome", get_title
        assert_text_present 'User'
        assert_text_present 'Password'
        assert_text_present 'Congratulations! Motiro was installed correctly'
        assert_text_present 'Edit (requires authentication)'
        assert_text_present 'Upcoming events'
        assert_text_present 'Latest news from Subversion'
        assert_text_present 'Motiro version'
    end
    
    def test_switches_languages_when_logged_in
      open '/en'
      
      type 'user_login', 'bob'
      type 'user_password', 'test'
      
      click 'login'
      wait_for_page_to_load(1500)
      
      assert_text_present 'Welcome, bob'
      assert_element_present "//a[text() = 'Edit']"
      
      click "//a[@id='pt-BR']"
      wait_for_page_to_load(1500)

      assert_text_present 'Bem-vindo, bob'
      assert_element_present "//a[text() = 'Editar']"
    end
    
    def teardown
        Page.destroy_all
        Page.connection.commit_db_transaction
    end

    
end

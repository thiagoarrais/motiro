class MainPageAcceptanceTest < SeleniumTestCase

    fixtures :pages, :users

    def test_main_page
        open '/'
        assert_equal "Motiro: Bem-vindo", get_title
        assert_element_present "//div[@id='description']"
        assert_text_present "Seja bem-vindo!"
        assert_text_present 'Motiro vers' #Motiro versão 0.3.2
        assert_text_present '0.3.2'
    end
        
    def test_report_html
        open '/report/subversion'
        assert_text_present 'cias do Subversion' #Últimas notícias do Subversion
        click "//img[starts-with(@src, '/images/rss.png')]"
        wait_for_page_to_load(500)
        assert_location "/feed/subversion"
    end
    
    def test_subversion_on_main
        open('/')
        assert_element_present "//div[@id = 'svn']"
        assert get_text("//div[@id = 'svn']").match(/cias do Subversion/) #regexp:Últimas notícias do Subversion
    end
    
    def test_events_on_main
        open('/')
        assert_element_present "//div[@id = 'events']"
        assert get_text("//div[@id = 'events']").match(/ximos eventos/) #regexp:Próximos eventos
    end
    
    def test_edition_disabled_without_authentication
        open('/')
        assert_element_present "//span[@class = 'disabled']"
        assert_equal "Editar (identifique-se, por favor)",
                     get_text("//span[@class = 'disabled']")
        
    end
    
    def test_welcomes_user
        open('/')
        type 'user_login', 'bob'
        type 'user_password', 'test'
        
        click 'login'
        wait_for_page_to_load(1000)
        
        assert_text_present 'Bem-vindo, bob'
    end

    def test_edition_enabled_when_authenticated
        open('/')
        type 'user_login', 'bob'
        type 'user_password', 'test'
        
        click 'login'
        wait_for_page_to_load(1000)
        
        assert_location '/'
        
        assert_element_present "//a[text() = 'Editar']"
        click "//a[text() = 'Editar']"
        
        #open('/edit.html')

        wait_for_page_to_load(1000)

        assert_element_present "//input[@name='btnSave']"
        assert_element_present "//input[@name='btnCancel']"
        assert_element_present "//textarea[@id='txaEditor']"
    end
    
end

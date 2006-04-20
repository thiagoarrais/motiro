class MotiroAcceptanceTest < Test::Unit::TestCase

    def test_main_page
        open '/'
        assert_equal "Motiro: Bem-vindo", get_title
        assert_element_present "//div[@id='description']"
        assert_text_present "Seja bem-vindo!"
        assert_text_present 'Motiro vers' #Motiro versão 0.2
        assert_text_present '0.2'
    end
        
    def test_report_html
        open '/report/subversion'
        assert_text_present 'cias do Subversion' #Últimas notícias do Subversion
        assert_element_present "//img[starts-with(@src, '/images/rss.gif')]"
        click "//img[starts-with(@src, '/images/rss.gif')]"
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
    
end

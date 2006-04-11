class MotiroAcceptanceTest < Test::Unit::TestCase

    def test_main_page
        open '/'
        assertTitle "Motiro: Bem-vindo"
        assertElementPresent "//div[@id='description']"
        assertTextPresent "Seja bem-vindo!"
        assertTextPresent "Motiro versão 0.2"
    end
        
    def test_report_html
        open '/report/subversion'
        assertTextPresent 'Últimas notícias do Subversion'
        assertElementPresent "//img[starts-with(@src, '/images/rss.gif')]"
        clickAndWait "//img[starts-with(@src, '/images/rss.gif')]"
        assertLocation "/feed/subversion"
    end
    
    def test_subversion_on_main
        open('/')
        assertElementPresent "//div[@id = 'svn']"
        assertText "//div[@id = 'svn']", 'regexp:Últimas notícias do Subversion'
    end
    
    def test_events_on_main
        open('/')
        assertElementPresent "//div[@id = 'events']"
        assertText "//div[@id = 'events']", 'regexp:Próximos eventos'
    end
    
end
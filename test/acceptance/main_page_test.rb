require File.dirname(__FILE__) + "/../../vendor/selenium/seletest"

class MotiroAcceptanceTest < Test::Unit::TestCase

    # Update server_info with your host and port
    def server_info
        ['localhost', 3000]
    end


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
        assertElementPresent "//img[@src='/images/rss.gif']"
        clickAndWait "//img[@src='/images/rss.gif']"
        assertLocation "/feed/subversion"
    end
    
    def test_subversion_on_main
        open('/')
        assertElementPresent "//div[@id = 'svn']"
        assertTextPresent 'Últimas notícias do Subversion'
    end
    
end
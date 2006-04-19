require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + "/../../vendor/selenium/selenium"

class MotiroAcceptanceTest < Test::Unit::TestCase

    def setup
        @sel = Selenium::SeleneseInterpreter.new("localhost", 4444,
                        "*firefox", "http://localhost:3000", 15000)
        @sel.start
    end
  
    def test_main_page
        @sel.open '/'
        assert_equal "Motiro: Bem-vindo", @sel.get_title
        @sel.assert_element_present "//div[@id='description']"
        @sel.assert_text_present "Seja bem-vindo!"
        @sel.assert_text_present 'Motiro vers' #Motiro versão 0.2
        @sel.assert_text_present '0.2'
    end
        
    def test_report_html
        @sel.open '/report/subversion'
        @sel.assert_text_present 'cias do Subversion' #Últimas notícias do Subversion
        @sel.assert_element_present "//img[starts-with(@src, '/images/rss.gif')]"
        @sel.click "//img[starts-with(@src, '/images/rss.gif')]"
        @sel.wait_for_page_to_load(500)
        @sel.assert_location "/feed/subversion"
    end
    
    def test_subversion_on_main
        @sel.open('/')
        @sel.assert_element_present "//div[@id = 'svn']"
        assert @sel.get_text("//div[@id = 'svn']").match(/cias do Subversion/) #regexp:Últimas notícias do Subversion
    end
    
    def test_events_on_main
        @sel.open('/')
        @sel.assert_element_present "//div[@id = 'events']"
        assert @sel.get_text("//div[@id = 'events']").match(/ximos eventos/) #regexp:Próximos eventos
    end
    
    def teardown
        @sel.stop
    end

private
    
    def method_missing(name, *args)
        @sel.send(name, args)
    end
    
end
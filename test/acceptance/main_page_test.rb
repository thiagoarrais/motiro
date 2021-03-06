#  Motiro - A project tracking tool
#  Copyright (C) 2006-2008  Thiago Arrais
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

class MainPageAcceptanceTest < SeleniumTestCase
  
  fixtures :pages
  
  def test_report_html
    open '/report/subversion/en'
    assert_text_present 'Latest news from Subversion'
    assert_element_present "//a[@href = '/report/subversion/en.xml']/img[starts-with(@src, '/images/rss.png')]"
  end
  
  def test_subversion_on_main
    open('/en')
    assert_element_present "//div[@id = 'subversion']"
    assert get_text("//div[@id = 'subversion']").match(/Latest news from Subversion/)
  end
  
  def test_events_on_main
    open('/en')
    assert_element_present "//div[@id = 'events']"
    assert get_text("//div[@id = 'events']").match(/Scheduled events/)
  end
  
  def test_planned_features_on_main
    open('/en')
    assert_element_present "//div[@id = 'nextrelease']"
    assert get_text("//div[@id = 'nextrelease']").match(/Planned features/)
  end
  
  def test_shows_installation_sucessful_page_with_absent_main_page
    Page.delete_all("name = 'MainPage'")

    open('/en')
    assert_text_present 'Congratulations! Motiro was installed correctly'
  end
  
  def test_switches_languages_when_not_logged_in
    Page.delete_all("name = 'MainPage'")

    open('/')
    click "//a[@id='pt-BR']"
    wait_for_page_to_load(1000)
    
    assert_equal "Motiro: Bem-vindo", get_title
    assert_text_present 'Usu' # TODO Usuário
    assert_text_present 'Senha'
    assert_text_present 'instalou o Motiro corretamente'
    assert_text_present 'Editar (identifique-se, por favor)'
    assert_text_present 'Eventos agendados'
    assert_text_present 'ltimas not' # TODO Últimas notícias do Subversion
    assert_text_present 'cias do Subversion'
    assert_text_present 'Antigas'
    assert_text_present 'Funcionalidades planejadas'
    
    click "//a[@id='en']"
    wait_for_page_to_load(1000)
    
    assert_equal "Motiro: Welcome", get_title
    assert_text_present 'User'
    assert_text_present 'Password'
    assert_text_present 'Congratulations! Motiro was installed correctly'
    assert_text_present 'Edit (requires authentication)'
    assert_text_present 'Scheduled events'
    assert_text_present 'Latest news from Subversion'
    assert_text_present 'Older'
    assert_text_present 'Planned features'
  end
  
  def test_do_not_display_breadcrumbs_on_main_page
    open('/')
    
    assert_text_not_present 'You are here'
    assert_text_not_present 'Home'
  end
  
end

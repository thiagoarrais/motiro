#  Motiro - A project tracking tool
#  Copyright (C) 2006-2007  Thiago Arrais
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

require File.dirname(__FILE__) + '/../test_helper'
require 'wiki_controller'
require 'test_configuration'

# Re-raise errors caught by the controller.
class WikiController; def rescue_action(e) raise e end; end

class WikiControllerTest < Test::Unit::TestCase

  include TestConfiguration
  
  fixtures :users, :pages, :revisions

  def setup
    @controller = WikiController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_routes_to_nil_locale_when_not_specified_on_url
    assert_routing('/wiki/edit/MainPage', :controller => 'wiki',
                                          :action => 'edit',
                                          :page_name => 'MainPage')
  end

  def test_routes_to_specified_locale_page
    assert_routing('/wiki/show/MainPage/en', :controller => 'wiki',
                                             :action => 'show',
                                             :page_name => 'MainPage',
                                             :locale => 'en')
  end
  
  def test_blocks_edition
    log_as 'bob'
    
    page_name = pages('johns_page').name
    
    get :edit, { :page_name => page_name }
    assert_redirected_to :action => 'show', :page_name => page_name
  end
  
  def test_blocks_saving_pages_for_unauthorized_users
    log_as 'john'
  
    page_name = pages('bob_and_erics_page').name
    
    post :save, { :page_name => page_name,
                  :page => { :text => 'New text',
                             :editors => 'john' },
                  'btnSave' => true }
    
    assert flash[:not_authorized]
    assert_redirected_to :action => 'show', :page_name => page_name
  end
  
  def test_asks_page_provider_for_pages_when_editing
    FlexMock.use do |page_provider|
      page_provider.should_receive(:find_by_name).
          with('TestPage').
          once.
          and_return(Page.new(:name => 'TestPage'))
      @controller = WikiController.new(page_provider)

      ensure_logged_in
      get :edit, {:page_name => 'TestPage'}
      assert_response :success
    end
  end
  
  def test_authentication_required_for_edition
     get :edit, :page_name => 'TestPage'
     assert_redirected_to(:action => 'show', :page_name => 'TestPage')
  end
  
  def test_only_original_author_can_change_editors_list
    log_as 'eric'
    
    page_name = pages('bob_and_erics_page').name
    post :save, :page_name => page_name,
                :page => { :text => 'New page text',
                           :editors => 'bob eric john'},
                :btnSave => true
    
    log_as 'john'
    
    get :edit, :page_name => page_name
    assert flash[:not_authorized]
  end
  
  def test_noone_can_change_the_original_author
    bob = users('bob')
    page_name = pages('johns_page').name
    
    log_as 'john'
    
    post :save, :page_name => page_name,
                :btnSave => true, 
                :page => { :original_author_id => bob.id,
                           :editors => 'john bob' }
                
    log_as 'bob'
    
    get :edit, :page_name => page_name
    assert_no_tag :tag => 'label', :attributes => { :for => 'txtAuthorized' }
  end

  def test_uses_language_provided_by_address
    FlexMock.use do |provider|
        provider.should_receive(:find_by_name).
          with_any_args.
          and_return(mocked_page).
          once
        
        @controller = WikiController.new(provider)

        get :show, {:page_name => 'TestPage', :locale => 'en'}
        assert_tag :content => /You've been mocked!/
        assert_no_tag :content => /Você foi enganado!/
     end
  end
  
  def test_renders_page_in_default_language_when_not_specified
    FlexMock.use do |provider|
        provider.should_receive(:find_by_name).
          with_any_args.
          and_return(mocked_page).
          once

        @controller = WikiController.new(provider)

        get :show, {:page_name => 'TestPage'}
        assert_tag :content => /You've been mocked!/
        assert_no_tag :content => /Você foi enganado!/
     end
  end
  
  def test_considers_last_chosen_language_when_displaying_not_found_page
    get '/en'
    
    get :show, :page_name => 'NotYetCreatedPage'
    assert_tag :content => /nothing to be read here/
  end
  
  def test_auto_selects_page_kind
    log_as 'bob'
    
    get :new, :kind => 'feature'
    assert_tag :tag => 'option', :attributes => { :value => 'feature',
                                                  :selected => 'selected' }    
  end
  
  def test_inserts_page_name_as_title_on_edition
    log_as 'bob'
    
    get :edit, :page_name => 'BrandNewPage'
    assert_tag :tag => 'input', :attributes => { :type => 'text',
                                                 :value => 'Brand new page' }
  end
  
  def test_shows_page_title_with_page_title_class
    non_matching_title_page = pages('non_matching_title_page')
    get :show, :page_name => pages('test_page').name
    assert_tag :tag => 'span', :content => 'Test page',
               :attributes => { :class => 'page-title' }    

    get :show, :page_name => non_matching_title_page.name
    assert_tag :tag => 'span', :content => non_matching_title_page.title,
               :attributes => { :class => 'page-title' }    
  end
  
  def test_saves_last_editor_and_modification_date
    log_as 'john'
    
    post :save, :btnSave => true, 
                :page => { :title => 'Page written by John',
                           :text => 'Anyone can change it',
                           :kind => 'feature',
                           :editors => '' }
    
    page = Page.find_by_name('PageWrittenByJohn')
    
    assert_equal users('john'), page.last_editor
    assert_in_delta Time.now, page.modified_at, 1.0
    
    log_as 'bob'
    
    post :save, :page_name => 'PageWrittenByJohn',
                :btnSave => true, 
                :page => { :title => 'Page written by John',
                           :text => 'Bob changed the text',
                           :kind => 'feature',
                           :editors => '' }
    page = Page.find_by_name('PageWrittenByJohn')
    
    assert_equal users('bob'), page.last_editor
  end
  
  def test_shows_modification_editor_and_date_on_wiki_pages
    log_as 'john'
    
    post :save, :page_name => 'AnotherBoringWikiPage',
                :btnSave => true, 
                :page => { :title => 'Another boring wiki page',
                           :text => 'Some boring text',
                           :kind => 'common',
                           :editors => '' }
                           
    expected_time = Time.now.to_s(:rfc822).slice(0, 19) # Wed, 03 Jan 2007 00
    assert_redirected_to :action => 'show', :page_name => 'AnotherBoringWikiPage'
    follow_redirect
    assert_tag :content => /john/
    assert_tag :content => Regexp.new(expected_time)
  end
  
  def test_displays_date_edition_field_when_editing_events
    log_as 'bob'
    
    get :edit, :page_name => pages('release_event').name
    
    assert_xml_element "//select[@id = 'page_happens_at_1i']"
  end
  
  def test_displays_date_when_detailing_events
    get :show, :page_name => pages('release_event').name
    
    assert_tag :content => /This event was planned for  24 January 2007/
  end

  def test_does_not_try_to_display_date_when_detailing_common_pages
    get :show, :page_name => pages('test_page').name
    
    assert_no_tag :content => /This event was planned for/
  end
  
  def test_shows_breadcrumbs_trail_for_common_wiki_pages
    test_page = pages('test_page')
    get :show, :page_name => test_page.name
    
    assert_xml_element "//div[@id = 'crumbs' and contains(text(), 'You are here')]/a[@href = '/' and text() = 'Home']"
    assert_xml_element "//div[@id = 'crumbs']/a[@href = '/wiki/show/#{test_page.name}' and text() = '#{test_page.title}']"
  end
  
  def test_follows_breadcrumbs_trail_til_the_revision_number
    page = pages('changed_page')
    get :show, :page_name => page.name, :revision => '1'
    
    assert_xml_element "//div[@id = 'crumbs']/a[@href = '/wiki/show/#{page.name}?revision=1' and text() = 'Revision 1']"
  end

  def test_shows_breadcrumbs_trail_for_special_wiki_pages
    release_event = pages('release_event')
    get :show, :page_name => release_event.name
    
    assert_xml_element "//div[@id = 'crumbs' and contains(text(), 'You are here')]/a[@href = '/' and text() = 'Home']"
    assert_xml_element "//div[@id = 'crumbs']/a[@href = '/report/older/events' and text() = 'Events']"
    assert_xml_element "//div[@id = 'crumbs']/a[@href = '/wiki/show/#{release_event.name}' and text() = '#{release_event.title}']"
  end
  
  def test_shows_history_summary_and_details_for_new_wiki_pages
    log_as :bob
    post :save, :page_name => 'RevisedPage',
                :btnSave => true, 
                :page => { :title => 'The title will be changed',
                           :text => 'Some very boring text',
                           :kind => 'common',
                           :editors => '' }
    post :save, :page_name => 'RevisedPage',
                :btnSave => true, 
                :page => { :title => 'The title was changed',
                           :text => 'A little more exciting text',
                           :kind => 'common',
                           :editors => '' }

    log_out                       

    get :history, :page_name => 'RevisedPage'
    
    assert_tag :tag => 'a', :attributes => {
                 :href => @controller.url_for(
                   :controller => 'wiki', :action => 'show',
                   :page_name => 'RevisedPage', :revision => '1')},
               :content => /The title will be changed/
    assert_tag :content => /The title was changed/

    get :show, :page_name => 'RevisedPage', :revision => '1'
    assert_tag :content => /Some very boring text/

    get :show, :page_name => 'RevisedPage', :revision => '2'
    assert_tag :content => /A little more exciting text/
  end
  
  def test_displays_old_text_when_showing_revisions
    get :show, :page_name => pages('changed_page').name, :revision => '1'
    assert_tag :content => revisions('page_creation').text

    get :show, :page_name => pages('changed_page').name, :revision => '2'
    assert_tag :content => revisions('page_edition').text
  end

  def test_shows_version_number_for_page_revisions
    get :show, :page_name => pages('changed_page').name, :revision => '1'
    assert_tag :content => '(Revision 1)'

    get :show, :page_name => pages('changed_page').name, :revision => '2'
    assert_tag :content => '(Revision 2)'
  end

  def tests_shows_number_of_available_revisions
    get :show, :page_name => pages('changed_page').name
    
    assert_tag :content => 'Page history (2 revisions)'
  end

private

  def log_as(user_name)
    @request.session[:user] = users(user_name)
  end
  
  def log_out
    @request.session[:user] = nil
  end
  
  def mocked_page
    Page.new(:name => 'MockedPage').
      revise(bob, now, :title => 'Mocked page', :kind => 'common',
                       :text => "You've been mocked!\n\n--- pt-br ----\n\nVocê foi enganado!")
  end
  
end

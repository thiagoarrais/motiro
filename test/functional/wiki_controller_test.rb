#  Motiro - A project tracking tool
#  Copyright (C) 2006  Thiago Arrais
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
  
  fixtures :users, :pages

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
          and_return(Page.new(:name => 'TestPage',
                                :text => ''))
      @controller = WikiController.new(page_provider)

      ensure_logged_in
      get :edit, {:page_name => 'TestPage'}
      assert_response :success
    end
  end
  
  def test_authentication_required_for_edition
     get :edit, { :page_name => 'TestPage' }
     assert_redirected_to(:controller => 'account', :action => 'login')
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

  def test_askes_page_to_render_in_specific_language
    FlexMock.use('provider', 'page') do |provider, page|
        provider.should_receive(:find_by_name).
          with_any_args.
          and_return(page).
          once
        page.should_receive(:render_html).
          with('en').
          and_return("<div>You've been mocked!").
          once
        
        @controller = WikiController.new(provider)

        get :show, {:page_name => 'TestPage', :locale => 'en'}
        assert_response :success
     end
  end
  
  def test_askes_page_to_render_in_default_language
    FlexMock.use('provider', 'page') do |provider, page|
        provider.should_receive(:find_by_name).
          with_any_args.
          and_return(page).
          once
        page.should_receive(:render_html).
          with(nil).
          and_return("<div>You've been mocked!</div>").
          once
        
        @controller = WikiController.new(provider)

        get :show, {:page_name => 'TestPage'}
        assert_response :success
     end
  end
  
private

  def log_as(user_name)
    @request.session[:user] = users(user_name)
  end
  
end

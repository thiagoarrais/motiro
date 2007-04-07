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

class PageTest < Test::Unit::TestCase
  fixtures :pages, :revisions, :users
  
  def test_is_open_to_all
    attrs = { :text => 'Page text' }
    assert !revise_named_page(attrs.merge(:editors => 'john')).is_open_to_all?
    assert  revise_named_page(attrs.merge(:editors => '')).is_open_to_all?
    assert  revise_named_page(attrs.merge(:editors => '  ')).is_open_to_all?
    assert !revise_named_page(attrs.merge(:editors => '  john ')).is_open_to_all?
    assert  revise_named_page(attrs.merge(:editors => "\n")).is_open_to_all?
  end
  
  def test_fresh_page_is_open_to_all
    assert Page.new(:name => 'FreshPage').is_open_to_all?
  end
  
  def test_fresh_page_has_empty_editors_list
    assert_equal 0, Page.new(:name => 'AnotherFreshPage').editors.size
  end
  
  def test_page_name_is_title_camelized
    assert_equal 'HowToWriteAMotiroPage',
                 revise_brand_new_page(:title => 'How to write a Motiro page').name
  end
  
  def test_user_entered_page_name_takes_precedence_over_camelized_title
    page = Page.new(:name => 'MyFirstPageName')
    page.revise(bob, now, :title => 'My first page title')
    
    assert_equal 'MyFirstPageName', page.name  
  end
  
  def test_converts_utf8_decorated_vowels_when_generating_name
    assert_equal 'MinhaPagina',
                 revise_brand_new_page(:title => 'Minha página').name
    assert_equal 'AaaaaEeeeIiiiiYyyOooooUuuuu',
                 revise_brand_new_page(:title => 'ãàáâä èéêë ĩìíîï ÿýý õòóôö ũùúûü').name
    assert_equal 'AaaaaEeeeIiiiiYyOooooUuuuu',
                 revise_brand_new_page(:title => 'ÃÀÁÂÄ ÈÉÊË ĨÌÍÎÏ ÝŸ ÕÒÓÔÖ ŨÙÚÛÜ').name
  end
  
  def test_converts_utf8_decorated_consonants_when_generating_name
    assert_equal 'ElNino', revise_brand_new_page(:title => 'El Niño').name
    assert_equal 'NnCcSrlzNnCcSrlz',
                 revise_brand_new_page(:title => 'ñń ćç śŕĺź ÑŃ ÇĆ ŚŔĹŹ').name
  end

  def test_drops_non_alpha_numeric_characters_when_generating_name
    assert_equal 'ThisHasLotsOfPunctuation',
                 revise_brand_new_page(:title => 'This, has. lots! of? punctuation').name
    assert_equal 'TitleWithSomeStrangeCharacters',
                 revise_brand_new_page(:title => 'Title%with$some&strange*characters').name
  end

  def test_resolves_clashing_page_names
    fst_page = revise_brand_new_page(:title => 'My first Motiro page', :text => '')
    assert_equal 'MyFirstMotiroPage', fst_page.name
    fst_page.save
    
    snd_page = revise_brand_new_page(:title => 'My first Motiro page', :text => '')
    assert_equal 'MyFirstMotiroPage2', snd_page.name
    snd_page.save
    
    trd_page = revise_brand_new_page(:title => 'My first Motiro page')
    assert_equal 'MyFirstMotiroPage3', trd_page.name
  end
  
  def test_uses_place_holder_title_when_nil
    assert_equal PLACE_HOLDER_TITLE.t, Page.new.title
  end
  
  def test_uses_place_holder_title_when_empty
    page = Page.new(:title => '')
    
    assert_equal PLACE_HOLDER_TITLE.t, page.title    
  end
  
  def test_uses_kind_based_title_when_revised_with_empty_title
    page = revise_brand_new_page(:kind => 'feature', :title => '')
    
    assert_equal 'Feature page', page.title    
  end
  
  def test_translates_default_title
    Locale.set 'pt-br'
    
    assert_equal 'Digite o título aqui', Page.new.title  
  end
  
  def test_saves_default_title_based_on_page_kind_when_title_is_place_holder
    common_page = Page.new
    
    common_page.save
    assert_equal 'Common page', common_page.title
    
    feature_page = revise_brand_new_page(:kind => 'feature')
    assert_equal 'Feature page', feature_page.title
  end
  
  def test_numbers_titles_when_already_used
    revise_brand_new_page({})
    
    snd_page = revise_brand_new_page({})
    assert_equal 'Common page 2', snd_page.title
    
    trd_page = revise_brand_new_page({})
    assert_equal 'Common page 3', trd_page.title
  end
  
  def test_generates_page_title_based_on_name
    page = Page.new(:name => 'YetAnotherMotiroPage')
    
    assert_equal 'Yet another motiro page', page.title
  end
  
  def test_revising_new_page_should_record_original_author_id_and_editors
    john = users(:john)
    time = Time.local(2007, 3, 15, 17, 3, 22)
    page = Page.new(:name => 'BrandNew').revise(john, time,
                                                :kind => 'feature',
                                                :title => 'Brand new page',
                                                :text => 'This is a new page',
                                                :editors => 'john bob eric')
                 
    assert_equal john, page.last_editor
    assert_equal john, page.original_author
    assert_equal time, page.modified_at
    assert_equal 'feature', page.kind
    assert_equal 'Brand new page', page.title
    assert_equal 'This is a new page', page.text
    assert_equal 'john bob eric', page.editors
  end
  
  def test_revising_old_page_should_not_record_original_author_id
    john = users('john')
    time = Time.local(2007, 3, 15, 17, 3, 22)
    page = pages(:bob_and_erics_page).revise(john, time,
                                             :title => "Bob and Eric's page",
                                             :text => 'Do not touch')
                 
    assert_equal john, page.last_editor
    assert_equal users('bob'), page.original_author
    assert_equal time, page.modified_at
    assert_equal "Bob and Eric's page", page.title
    assert_equal 'Do not touch', page.text
  end
  
  def test_only_original_author_should_be_able_to_change_editors_list
    john = users('john')
    editors = pages(:bob_and_erics_page).editors 
    page = pages(:bob_and_erics_page).revise(john, Time.local(2007, 3, 15, 17),
                                             :title => "Bob and Eric's page",
                                             :text => 'Do not touch',
                                             :editors => 'john lennon')
                 
    assert_not_equal 'john lennon', editors
    assert_equal editors, page.editors
  end
  
  def test_keeps_revision_record
    page = create_page_with_one_revision
    assert_equal 1, page.revisions.size

    page.revise(users('john'), Time.local(2007, 3, 15, 10, 19, 36),
                :title => 'Revised page',
                :text => 'Page revision number 2',
                :editors => '')
    
    assert_equal 2, page.revisions.size
    assert_equal 'Page revision number 2', page.revisions.first.text
    assert_equal 'Page revision number 1', page.revisions.last.text
  end
  
  def test_copies_previous_editors_list_when_not_provided
    page = create_page_with_one_revision
    previous_editors = page.editors
    
    page.revise(users('bob'), Time.now, :title => page.title,
                                        :text => 'Bob was here')
    
    assert_equal previous_editors, page.editors
    assert_equal previous_editors, page.revisions.first.editors
    assert_equal previous_editors, page.revisions.last.editors
  end
  
  def test_most_recent_revision_comes_first
    page = pages('changed_page')
    assert_equal revisions('page_creation'), page.revisions[1]
    assert_equal revisions('page_edition'), page.revisions[0]
  end
  
  def test_records_original_author_for_pages_without_author
    page = pages('nobodys_page')
    bob = users('bob')
    assert_nil page.original_author
    
    page.revise(bob, now, :title => page.title, :text => 'Bob was here')
                                        
    assert_equal bob, page.original_author                      
  end
  
  def test_copies_previous_kind_when_not_provided
    page = pages('list_last_modified_features_page')
    
    page.revise(bob, now, :text => 'New feature page text')
    
    assert_equal 'feature', page.kind
  end
  
  def test_stores_revisions_for_happens_at
    event = pages('release_event')
    old_time = event.happens_at
    new_time = Date.new(2007, 4, 4)
    
    event.revise(bob, now, :happens_at => new_time)
    
    assert_equal new_time, event.happens_at
    assert_equal new_time, event.revisions.first.happens_at
    assert_equal old_time, event.revisions.last.happens_at
  end
  
  def test_rbab
    date = Date.new(2007, 4, 4)
    page = revise_brand_new_page(:kind => 'event',
                                 :text => 'Something will happen',
                                 :happens_at => date)
    
    assert_equal date, page.happens_at
  end
  
  #TODO it seems that event pages do not get their happens_at attribute revised
  
private
  
  def create_page_with_one_revision
    Page.new(:name => 'RevisedPage').revise(
      users('john'), Time.local(2007, 3, 15, 9, 15, 53),
      :title => 'Revised page',
      :text => 'Page revision number 1',
      :editors => '')
  end

end

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

require File.dirname(__FILE__) + '/../test_helper'

class PageTest < Test::Unit::TestCase
  fixtures :pages, :revisions, :users
  
  def teardown
    WikiReference.delete_all
  end

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
  
  def test_fresh_page_shows_default_text
    assert_equal WIKI_NOT_FOUND_TEXT, Page.new(:name => 'FreshPage').text
  end
  
  def test_default_text_for_main_page_shows_some_appraisal
    assert_equal CONGRATS_TEXT, Page.new(:name => 'MainPage').text
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
    fst_page = revise_brand_new_page(:title => 'My first Motiro page', :text => 'aaa')
    assert_equal 'MyFirstMotiroPage', fst_page.name
    fst_page.save
    
    snd_page = revise_brand_new_page(:title => 'My first Motiro page', :text => 'aaa')
    assert_equal 'MyFirstMotiroPage2', snd_page.name
    snd_page.save
    
    trd_page = revise_brand_new_page(:title => 'My first Motiro page')
    assert_equal 'MyFirstMotiroPage3', trd_page.name
  end
  
  def test_uses_place_holder_title_when_nil
    assert_equal PLACE_HOLDER_TITLE.t, Page.new.title
  end
  
  def test_uses_place_holder_title_for_new_pages
    assert_equal PLACE_HOLDER_TITLE.t, Page.new.title    
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
    common_page = Page.new.revise(bob, now, :title => PLACE_HOLDER_TITLE.t)
    
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
    assert_equal 'Page revision number 2', page.revisions.last.text
    assert_equal 'Page revision number 1', page.revisions.first.text
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
    assert_equal revisions('page_creation'), page.revisions[0]
    assert_equal revisions('page_edition'), page.revisions[1]
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
    assert_equal new_time, event.revisions.last.happens_at
    assert_equal old_time, event.revisions.first.happens_at
  end
  
  def test_stores_feature_status_revisions
    feature = pages('list_last_modified_features_page')
    feature.revise(bob, now, :done => 1)
    
    assert  feature.done?
    assert  feature.revisions.last.done?
    assert !feature.revisions.first.done?
  end
  
  def test_rbab
    date = Date.new(2007, 4, 4)
    page = revise_brand_new_page(:kind => 'event',
                                 :text => 'Something will happen',
                                 :happens_at => date)
    
    assert_equal date, page.happens_at
  end
  
  def test_writes_modification_time_to_own_table_too
    written_page = revise_brand_new_page(:title => 'Modified page',
                                         :kind => 'common',
                                         :text => 'Modified now')
    
    assert_equal now, written_page.modified_at
    
    read_page = Page.find_by_modified_at_and_name(now, 'ModifiedPage')
    
    assert_not_nil read_page
    assert_equal written_page, read_page
  end
  
  def test_numbers_revisions
    page = create_page_with_one_revision
    
    assert_equal 1, page.revisions.size
    assert_equal 1, page.revisions[0].position
    
    page.revise(bob, now, :text => 'Modified text')

    assert_equal 2, page.revisions.size
    assert_equal 2, page.revisions[1].position
  end
  
  def test_converts_to_headline
    page = revise_brand_new_page(:title => 'My page',
                                 :kind => 'common',
                                 :text => "This is my page and it is written \n" +
                                          "in English, German and \n" +
                                          "Portuguese\n\n" +
                                          "--- de ------\n\n" +
                                          "Dieses ist meine Seite und es ist \n" +
                                          "auf Englisch, Deutsch und Portugiese \n " +
                                          "geschrieben\n\n" +
                                          "--- pt-br ------\n\n" +
                                          "Esta é minha página e está escrita \n" +
                                          "em inglês, alemão e português")
    headline = page.to_headline
    assert_equal page.last_editor.login, headline.author
    assert_equal page.modified_at, headline.happened_at
    assert_equal "My page\n\n" + 
                 "This is my page and it is written \n" +
                 "in English, German and \n" +
                 "Portuguese\n\n" +
                 "--- de ---\n\n" +
                 "My page\n\n" +
                 "Dieses ist meine Seite und es ist \n" +
                 "auf Englisch, Deutsch und Portugiese \n " +
                 "geschrieben\n\n" +
                 "--- pt-br ---\n\n" +
                 "My page\n\n" +
                 "Esta é minha página e está escrita \n" +
                 "em inglês, alemão e português", headline[:description]
  end
  
  def test_event_page_uses_planned_date_as_headline_date
    event_date = Date.new(2007, 7, 1)
    event = revise_brand_new_page(:title => 'My event',
                                  :kind => 'event',
                                  :happens_at => event_date, 
                                  :text => "Let's get together and feel alright")
    assert_equal event_date.to_t, event.to_headline.happened_at
  end
  
  def test_pages_without_editor_or_modification_time_are_reported_as_modified_by_someone_at_some_time
    headline = Page.new(:name => 'VeryOldPage', :kind => 'common').to_headline
    assert_equal DEFAULT_AUTHOR, headline.author
    assert_equal DEFAULT_TIME, headline.happened_at
  end

  def test_records_wiki_references
    page = revise_brand_new_page(:title => 'Usual page',
                                 :kind => 'common',
                                 :text => "This is page has a link to the\n" +
                                          "[[MainPage|main page]] and to\n" +
                                          "the [[TestPage|test page]]")
    assert_equal 2, page.references.size
    assert_equal 2, page.refered_pages.size

    main_page, test_page = pages('main_page'), pages('test_page')

    assert_equal page, page.references.first.referer
    assert_equal main_page, page.references.first.referee
    assert_equal test_page, page.refered_pages.last
    assert_equal page, main_page.referrals.first.referer
    assert_equal page, test_page.refering_pages.first
  end

  def test_rebuilds_references_with_new_revision
    main_page, test_page = pages('main_page'), pages('test_page')
    page = revise_brand_new_page(:title => 'Usual page',
                                 :kind => 'common',
                                 :text => "Here is a [[MainPage|reference]]")

    assert_equal 1, page.refered_pages.size
    assert_equal 1, main_page.refering_pages.size

    page.revise(bob, now, :text => "Here is another [[TestPage|reference]]")
    main_page = Page.find_by_name('MainPage')

    assert_equal 1, page.refered_pages.size
    assert_equal 0, main_page.refering_pages.size
    assert_equal 1, test_page.refering_pages.size
    assert_equal test_page, page.references.first.referee
    assert_equal test_page, page.refered_pages.first
  end

  def test_referencing_an_empty_page_creates_it
    page = revise_brand_new_page(:title => 'Referencing page',
                                 :kind => 'common',
                                 :text => "You should go [[ReferedPage|there]]")

    refered_page = Page.find_by_name('ReferedPage')

    assert_not_nil refered_page
    assert_equal 1, refered_page.referrals.size
    assert_equal page, refered_page.refering_pages.first
    assert_equal WIKI_NOT_FOUND_TEXT, refered_page.text
  end

private
  
  def create_page_with_one_revision
    Page.new(:name => 'RevisedPage').revise(
      users('john'), Time.local(2007, 3, 15, 9, 15, 53),
      :title => 'Revised page',
      :text => 'Page revision number 1',
      :editors => '')
  end

end

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

require 'rubygems'

require 'flexmock'

require 'core/chief_editor'

require 'stub_hash'
require 'stubs/svn_settings'
require 'mocks/headline'

require 'mocks/svn_reporter'

class Class
  include Test::Unit::Assertions
end

class Headline
  @@old_latest = self.method(:latest)
  
  def self.old_latest(num, reporter)
    @@old_latest.call(num, reporter)        
  end
end                

class ChiefEditorTest < Test::Unit::TestCase
  
  fixtures :headlines, :changes
  
  @@log = ''
  
  def self.append_to_log(txt)
    @@log << txt
  end
  
  def test_reads_package_size
    def Headline.latest(num, reporter)
      assert_equal 6, num
      ChiefEditorTest.append_to_log('latest')
      return Array.new.fill(MockHeadline.new, 6)
    end

    FlexMock.use('1', '2') do |reporter, fetcher|
      fetcher.should_receive(:active_reporters).and_return([reporter]).once
      reporter.should_receive(:cache?).and_return(true)
      reporter.should_receive(:name).and_return('mock_subversion')
      settings = StubConnectionSettingsProvider.new(:package_size => 6)
      
      ChiefEditor.new(settings, fetcher).latest_news_from 'mock_subversion'
      
      assert_equal 'latest', @@log
    end
    
    def Headline.latest(num, reporter)
      old_latest(num, reporter)
    end
  end
  
  def test_refetches_latest_news_on_every_call_when_in_development_mode
    FlexMock.use do |reporter|
      settings = StubConnectionSettingsProvider.new(:update_interval => 0)
      fetcher = { :active_reporters => [reporter] }
      svn_demo_headline = headlines('svn_demo_headline')
      
      reporter.should_receive(:name).returns('subversion')
      reporter.should_receive(:latest_headlines).once.
        returns([].fill(MockHeadline.new, 0, 3))
      
      ChiefEditor.new(settings, fetcher).latest_news_from('subversion')
    end
  end
  
  def test_refetches_news_on_every_call_when_in_development_mode
    FlexMock.use do |reporter|
      settings = StubConnectionSettingsProvider.new(:update_interval => 0)
      fetcher = { :active_reporters => [reporter] }
      svn_demo_headline = headlines('svn_demo_headline')
      
      reporter.should_receive(:name).returns('subversion')
      reporter.should_receive(:headlines).once.
        returns([svn_demo_headline])
      
      ChiefEditor.new(settings, fetcher).news_from('subversion')
    end
  end

  def test_does_not_ask_reporter_in_production_mode
    FlexMock.use('1', '2') do |fetcher, reporter|
      reporter.should_receive(:cache?).and_return(true)
      reporter.should_receive(:name).and_return('mock_subversion')
      reporter.should_receive(:latest_headlines).never
      fetcher.should_receive(:active_reporters).and_return([reporter]).once
      
      settings = StubConnectionSettingsProvider.new(:update_interval => 6)
      
      ChiefEditor.new(settings, fetcher).latest_news_from 'mock_subversion'
    end
  end
  
  def test_asks_reporter_for_headline_in_development_mode
    FlexMock.use do |reporter|
      settings = StubConnectionSettingsProvider.new(:update_interval => 0)
      fetcher = { :active_reporters => [reporter] }
      svn_demo_headline = headlines('svn_demo_headline')
      
      reporter.should_receive(:name).
        returns('subversion')
      
      reporter.should_receive(:headline).
        with(svn_demo_headline.rid).
        returns(svn_demo_headline).
        once
      
      chief_editor = ChiefEditor.new(settings, fetcher)
      
      chief_editor.headline_with(svn_demo_headline.reported_by,
                                 svn_demo_headline.rid)
    end
  end
  
  def test_fetches_cached_headlines_in_production_mode
    FlexMock.use('1', '2') do |reporter, fetcher|
      fetcher.should_receive(:active_reporters).and_return([reporter])
      reporter.should_receive(:cache?).returns(true)
      reporter.should_receive(:name).returns('subversion')
      reporter.should_receive(:headline).never


      settings = StubConnectionSettingsProvider.new(:update_interval => 8)
      
      chief_editor = ChiefEditor.new(settings, fetcher)
      
      svn_demo_headline = headlines('svn_demo_headline')

      headline = chief_editor.headline_with(svn_demo_headline.reported_by,
                                            svn_demo_headline.rid)
      
      reporter.mock_verify
      
      assert_equal svn_demo_headline.description, headline.description
    end
  end
  
  def test_fetches_reporter_title
    settings = StubConnectionSettingsProvider.new
    title = 'Latest news from the mail list'
    reporter = { :name => 'mail_list', :channel_title => title }
    fetcher = { :active_reporters => [reporter]}
      
    chief_editor = ChiefEditor.new(settings, fetcher)
      
    assert_equal title, chief_editor.title_for('mail_list')
  end
  
  def test_fetches_title_from_cached_reporter
    settings = StubConnectionSettingsProvider.new
    title = 'Latest news from the mail list'
    reporter = { :name => 'mail_list',
                 :channel_title => title,
                 :cache? => true }
    fetcher = { :active_reporters => [reporter]}
      
    chief_editor = ChiefEditor.new(settings, fetcher)
      
    assert_equal title, chief_editor.title_for('mail_list')
  end

  def test_retrieves_headlines_from_correct_reporter_on_cached_mode
    FlexMock.use('1', '2', '3') do |events_reporter, svn_reporter, fetcher|
      settings = StubConnectionSettingsProvider.new(:update_interval => 8)
      
      events_reporter.should_receive(:name).returns('events')
      events_reporter.should_receive(:cache?).returns(true)
      svn_reporter.should_receive(:name).returns('subversion')
      svn_reporter.should_receive(:cache?).returns(true)
      fetcher.should_receive(:active_reporters).
        and_return([events_reporter, svn_reporter]).
        once
      
      chief_editor = ChiefEditor.new(settings, fetcher)
      
      events_news = chief_editor.latest_news_from 'events'
      
      assert_equal 2, events_news.size
      
      subversion_news = chief_editor.latest_news_from 'subversion'
      
      assert_equal 3, subversion_news.size
    end
  end
  
  def test_asks_fetcher_for_reporters_to_employ
    FlexMock.use('1', '2') do |fetcher, reporter|
      settings = StubConnectionSettingsProvider.new
      
      fetcher.should_receive(:active_reporters).once.
        returns([reporter, reporter])
      
      reporter.should_receive(:name).returns('fake_reporter').twice
      reporter.should_receive(:cache?).returns(true).twice
      
      editor = ChiefEditor.new(settings, fetcher)
    end
  end
  
  #TODO should signal when the reporter is not registered
end
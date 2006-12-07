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

require 'rubygems'

require 'flexmock'

require 'core/chief_editor'

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
    settings = StubConnectionSettingsProvider.new(:package_size => 6)
    
    chief_editor = ChiefEditor.new(settings)
    
    def Headline.latest(num, reporter)
      assert_equal 6, num
      ChiefEditorTest.append_to_log('latest')
      return Array.new.fill(MockHeadline.new, 6)
    end
    
    chief_editor.latest_news_from 'mock_subversion'
    
    assert_equal 'latest', @@log
    
    def Headline.latest(num, reporter)
      old_latest(num, reporter)
    end
  end
  
  def test_refetches_latest_news_on_every_call_when_in_development_mode
    settings = StubConnectionSettingsProvider.new(:update_interval => 0)
    
    chief_editor = ChiefEditor.new(settings)
    
    reporter = MockSubversionReporter.new
    
    chief_editor.employ reporter
    
    reporter.expect_latest_headlines do
      Array.new.fill(MockHeadline.new, 0, 3)
    end
    
    chief_editor.latest_news_from 'mock_subversion'
    
    reporter.verify
  end
  
  def test_refetches_news_on_every_call_when_in_development_mode
    FlexMock.use do |reporter|
      settings = StubConnectionSettingsProvider.new(:update_interval => 0)
      
      svn_demo_headline = headlines('svn_demo_headline')
      
      reporter.should_receive(:name).returns('subversion')
      
      reporter.should_receive(:headlines).once.
        returns([svn_demo_headline])
      
      chief_editor = ChiefEditor.new(settings)
      chief_editor.employ reporter
      chief_editor.news_from('subversion')
    end
  end

  def test_does_not_ask_reporter_in_production_mode
    settings = StubConnectionSettingsProvider.new(:update_interval => 6)
    
    chief_editor = ChiefEditor.new(settings)
    
    reporter = MockSubversionReporter.new
    
    chief_editor.employ reporter
    
    chief_editor.latest_news_from 'mock_subversion'
    
    reporter.verify
  end
  
  def test_askes_reporter_for_headline_in_development_mode
    FlexMock.use do |reporter|
      settings = StubConnectionSettingsProvider.new(:update_interval => 0)
      
      svn_demo_headline = headlines('svn_demo_headline')
      
      reporter.should_receive(:name).
        returns('subversion')
      
      reporter.should_receive(:headline).
        with(svn_demo_headline.rid).
        returns(svn_demo_headline).
        once
      
      chief_editor = ChiefEditor.new(settings)
      
      chief_editor.employ reporter
      
      chief_editor.headline_with(svn_demo_headline.reported_by,
                                 svn_demo_headline.rid)
    end
  end
  
  def test_fetches_cached_headlines_in_production_mode
    FlexMock.use do |reporter|
      settings = StubConnectionSettingsProvider.new(:update_interval => 8)
      
      svn_demo_headline = headlines('svn_demo_headline')
      
      reporter.should_receive(:name).returns('subversion')
      
      reporter.should_receive(:headline).never
      
      chief_editor = ChiefEditor.new(settings)
      
      chief_editor.employ reporter
      
      headline = chief_editor.headline_with(svn_demo_headline.reported_by,
                                            svn_demo_headline.rid)
      
      reporter.mock_verify
      
      assert_equal svn_demo_headline.description, headline.description
    end
  end
  
  def test_fetches_reporter_title
    FlexMock.use do |reporter|
      settings = StubConnectionSettingsProvider.new
      
      reporter.should_receive(:name).
      returns('mail_list')
      
      title = 'Latest news from the mail list'
      
      reporter.should_receive(:channel_title).returns(title)
      
      chief_editor = ChiefEditor.new(settings)
      chief_editor.employ reporter
      
      assert_equal title, chief_editor.title_for('mail_list')
    end
  end
  
  def test_retrieves_headlines_from_correct_reporter_on_cached_mode
    FlexMock.use('1', '2') do |events_reporter, subversion_reporter|
      settings = StubConnectionSettingsProvider.new(:update_interval => 8)
      
      events_reporter.should_receive(:name).returns('events')
      
      subversion_reporter.should_receive(:name).returns('subversion')
      
      chief_editor = ChiefEditor.new(settings)
      chief_editor.employ events_reporter
      chief_editor.employ subversion_reporter
      
      events_news = chief_editor.latest_news_from 'events'
      
      assert_equal 2, events_news.size
      
      subversion_news = chief_editor.latest_news_from 'subversion'
      
      assert_equal 3, subversion_news.size
    end
  end
  
  def test_askes_fetcher_for_reporters_to_employ
    FlexMock.use('1', '2') do |fetcher, reporter|
      settings = StubConnectionSettingsProvider.new
      
      fetcher.should_receive(:active_reporters).once.
        returns([reporter, reporter])
      
      reporter.should_receive(:name).twice.
        returns('fake_reporter')
      
      editor = ChiefEditor.new(settings, fetcher)
    end
  end
  
  #TODO should signal when the reporter is not registered
end
require File.dirname(__FILE__) + '/../test_helper'

class HeadlineTest < Test::Unit::TestCase
  fixtures :headlines, :changes
  
  def test_create
    headline = Headline.find(1)
    
    assert_equal 'raulseixas', headline.author
    assert_equal 'gita', headline.description
    assert_equal Time.local(2005, 1, 1), headline.happened_at
  end
  
  def test_latest_one
    hls = Headline.latest(1, 'subversion')
    hl = hls.first
    
    assert_equal 'o dia em que a terra parou', hl.description
  end
  
  def test_cached
    svn_demo_headline = headlines('svn_demo_headline')
    headline = Headline.new(:author => svn_demo_headline.author,
                            :description => svn_demo_headline.description,
                            :happened_at => [2006, 03, 23, 11, 10, 04])
    
    assert headline.cached?
  end
  
  def test_not_cached
    headline = Headline.new(:author => 'chicobuarque',
                            :description => 'a banda',
                            :happened_at => [1983, 1, 1])
    
    assert ! headline.cached?
  end
  
  def test_record_time
    headline = Headline.new(:author => 'thiagoarrais',
                            :description => 'fiz besteira',
                            :happened_at => [1983, 1, 1, 00, 15, 12])
    
    headline.save
    
    headline = Headline.find(:first,
                             :conditions => "author = 'thiagoarrais' and description = 'fiz besteira'")
    
    assert_equal Time.local(1983, 1, 1, 00, 15, 12), headline.happened_at
  end
  
  def test_cache_with_date_time
    aHeadline = Headline.new(:author => 'thiagoarrais',
                             :description => 'fiz besteira',
                             :happened_at => [1983, 1, 1, 00, 15, 12])
    aHeadline.save
    
    assert aHeadline.cached?
  end
  
  def test_cache_new
    aHeadline = Headline.new(:author => 'herbertvianna',
                             :description => 'this is a new headline',
                             :happened_at => [1983, 1, 1, 00, 15, 12])
    
    aHeadline.cache
    
    hls = Headline.find(:all, :conditions => ['author = ?', 'herbertvianna'])
    assert_equal(1, hls.size)
  end
  
  def test_cache_already_recorded
    contents = { :author => 'zeramalho',
                 :description => 'we will try to cache this headline twice',
                 :happened_at => [1983, 8, 8, 07, 15, 12] }
    Headline.new(contents).cache
    Headline.new(contents).cache
    hls = Headline.find(:all, :conditions => ['author = ?', 'zeramalho'])
    
    assert_equal(1, hls.size)
  end
  
  def test_search_by_reporter_name_and_rid
    svn_demo_headline = headlines('svn_demo_headline')
    aHeadline = Headline.find_with_reporter_and_rid(svn_demo_headline.reported_by,
                                                    svn_demo_headline.rid)
    
    assert_not_nil aHeadline
    assert_equal svn_demo_headline, aHeadline
  end
  
  def test_not_filled
    fst_change, snd_change = FlexMock.new, FlexMock.new
    
    fst_change.should_receive(:filled?).
    returns(true)
    snd_change.should_receive(:filled?).
    returns(false)
    
    a_headline = create_headline_with_changes(fst_change, snd_change)
    
    assert !a_headline.filled?
    
    [fst_change, snd_change].each do |m|
      m.mock_verify
    end
  end
  
  def test_filled
    change = FlexMock.new
    
    change.should_receive(:filled?).
    returns(true)
    
    a_headline = create_headline_with_changes(change, change)
    
    assert a_headline.filled?
    
    change.mock_verify
  end
  
  def test_recaches_failed
    filled_change = Change.new(:summary => 'A /trunk/app/models/headline.rb',
                               :resource_kind => 'file',
                               :diff => '+change')
    failed_change = Change.new(:summary => 'A /trunk/test/unit/headline_test.rb',
                               :resource_kind => 'file',
                               :diff => nil)
    
    a_headline = create_headline_with_changes(filled_change, failed_change)
    
    a_headline.cache
    
    failed_change.diff = '+def test_headline; end'
    
    a_headline = create_headline_with_changes(filled_change, failed_change)
    
    assert !a_headline.cached?
    
    a_headline.cache
    
    assert a_headline.cached?
    
    hls = Headline.find(:all, :conditions => ["description = ?",
                                              a_headline.description])
                                              
    assert_equal 1, hls.size
  end
  
  def test_empty_title_for_empty_description
    a_headline= Headline.new(:author => 'thiagoarrais',
                             :reported_by => 'subversion',
                             :description => "\n")
                             
    assert_equal '', a_headline.title(Translator.for(nil))
    assert_equal '', a_headline.title(Translator.for('en'))
  end

  def test_translating_title
    a_headline= Headline.new(:author => 'thiagoarrais',
                             :reported_by => 'subversion',
                             :description => "este eh o titulo da manchete\n" +
                                             "\n" +
                                             "--- en -----\n" +
                                             "\n" +
                                             "this is the headline title\n")
    
    assert_equal 'this is the headline title',
                 a_headline.title(Translator.for('en'))
    assert_equal 'este eh o titulo da manchete',
                 a_headline.title(Translator.for(nil))
  end
  
  def test_set_title_on_construction_and_retrieve_it
    a_headline = Headline.new(:author => 'thiagoarrais',
                              :title => 'this is the headline title',
                              :description => 'this is the description')
    
    assert_equal 'this is the headline title', a_headline.title
  end
  
  def test_translating_description
    english_description = "this is the headline title\n" +
                          "\n" +
                          "these are some commit details\n\n"
    portuguese_description = "este eh o titulo da manchete\n" +
                             "\n" +
                             "aqui vao os detalhes sobre o commit"
    a_headline = Headline.new(:author => 'thiagoarrais',
                              :description => english_description +
                                              "--- pt-BR ----\n\n" +
                                              portuguese_description)

    assert_equal english_description, a_headline.description(Translator.for('en'))
    assert_equal portuguese_description, a_headline.description(Translator.for('pt-BR'))
  end
  
  def test_unspecified_translation_returns_default_description
    english_description = "this is the headline title\n" +
                          "\n" +
                          "these are some commit details\n\n"
    portuguese_description = "este eh o titulo da manchete\n" +
                             "\n" +
                             "aqui vao os detalhes sobre o commit"
    a_headline = Headline.new(:author => 'thiagoarrais',
                              :description => english_description +
                                              "--- pt-BR ----\n\n" +
                                              portuguese_description)

    assert_equal english_description, a_headline.description
  end
  
  def test_extracts_title_with_carriage_returns
    a_headline = Headline.new :description => "this is the title\r\n\this is the description"
    
    assert_equal 'this is the title', a_headline.title
  end
  
  def test_does_not_recache_translated_headlines
    contents = { :author => 'ritalee',
                 :description => "this is the english description\n" +
                                 "\n" +
                                 "--- pt-BR --------\n" +
                                 "\n" +
                                 "esta eh a descricao em portugues",
                 :happened_at => [2006, 07, 25, 19, 21, 43] }
    
    Headline.new(contents).cache
    Headline.new(contents).cache
    hls = Headline.find(:all, :conditions => ['author = ?', 'ritalee'])
    
    assert_equal(1, hls.size)
  end
  
private
    
  def create_headline_with_changes(*changes)
    a_headline = Headline.new(:author => 'thiagoarrais',
                              :description => 'this is the headline title',
                              :reported_by => 'subversion',
                              :happened_at => [1983, 1, 1, 02, 15, 12],
                              :rid => 'r47')
    
    changes.reverse.each do |c|
      a_headline.changes.unshift(c)
    end
    
    return a_headline
  end
  
end

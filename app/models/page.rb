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

require 'rubygems'
require 'mediacloth'

require 'mediacloth_extensions'

PLACE_HOLDER_TITLE = 'Insert page title here'
DEFAULT_AUTHOR = 'someone'
DEFAULT_TIME = Time.local(2007, 1, 3, 15, 10)

class Page < ActiveRecord::Base

  has_many :revisions, :order => 'modified_at, id'
  has_many :references, :foreign_key => 'referer_id',
                        :class_name => 'WikiReference'
  has_many :referrals, :foreign_key => 'referee_id',
                       :class_name => 'WikiReference'
  has_many :refered_pages, :through => :references, :source => :referee
  has_many :refering_pages, :through => :referrals, :source => :referer
  
  def original_author
    oldest(:last_editor)
  end
  
  %w{modified_at last_editor done done?}.each do |attr|
    define_method attr do
      most_recent(attr)
    end
  end

  def title
    result = most_recent(:title)
    return title_from_name || PLACE_HOLDER_TITLE.t if result.nil? || result.empty?
    return result
  end
  
  def editors
    most_recent(:editors) || ''
  end
  
  def text
    most_recent(:text) ||
      ('MainPage' == self.name ? CONGRATS_TEXT : WIKI_NOT_FOUND_TEXT)  
  end
  
  def reported_by
    self.kind.pluralize
  end
  
  def after_initialize
    default('', :name)
    default('common', :kind)
  end
  
  def default(value, *attrs)
    attrs.each do |attr|
      cur = send(attr)
      send("#{attr}=".to_sym, value) if cur.nil? || cur.empty?
    end
  end
  
  def before_save
    if title == PLACE_HOLDER_TITLE.t
      revisions.last.title = title_from_kind  
    end
    
    write_attribute(:modified_at, self.modified_at)
    write_attribute(:name, self.name)
  end
  
  def name; name_before_type_cast; end
  def name_before_type_cast
    result = read_attribute(:name)
    return name_from_title if result.nil? || result.empty?
    return result
  end
  
  def is_open_to_all?
    0 == editors.strip.size
  end
  
  def revise(author, time, attrs)
    #TODO ugly! ugly! ugly!
    if !attrs[:happens_at] && attrs['happens_at(1i)'] && attrs['happens_at(2i)'] && attrs['happens_at(3i)'] 
      attrs[:happens_at] =
        Date.new(attrs['happens_at(1i)'].to_i, attrs['happens_at(2i)'].to_i,
                 attrs['happens_at(3i)'].to_i)
    end
    unless revisions.size == 0 || original_author 
      revisions.first.last_editor = author 
      revisions.first.save
    end
    rev = Revision.new(:last_editor => author, :modified_at => time,
                       :position => self.revisions.size + 1)
    rev.editors = if author.can_change_editors?(self)
      attrs[:editors]
    else
      revisions.last.editors
    end
    self.kind = attrs[:kind] if attrs[:kind]
    self.happens_at = attrs[:happens_at] if attrs[:happens_at]
    rev.kind, rev.happens_at = self.kind, self.happens_at
    rev.title, rev.text, rev.done = attrs[:title], attrs[:text], attrs[:done]
    update_references(rev.text) if rev.text
    self.revisions << rev
    
    save
    self
  end
  
  def to_headline
    #TODO (for 0.7): headlines and pages should _really_ be the same thing
    #                reporters should write ordinary wiki pages
    Headline.new(:rid => name,
                 :author => last_editor ? last_editor.login : DEFAULT_AUTHOR,
                 :happened_at => (kind == 'event' ? happens_at.to_t : modified_at) || DEFAULT_TIME,
                 :description => inject_title_into_text)
  end

private
  
  def update_references(input)
    self.references = []
    MediaCloth::wiki_render(input, :link_handler => reference_collector)
  end

  def reference_collector
    PageReferenceCollector.new(self)
  end

  def inject_title_into_text
    title + "\n\n" +
    text.gsub(/^--- (\S+) ----*[ \t\f]*\r?\n/,
              "--- \\1 ---\n\n#{title}\n")
  end
  
  def name_from_title
    sequence(Page, drop_non_alpha(clean(title)).downcase.gsub(/ /, '_').camelize, 'name')
  end
  
  def title_from_kind
    sequence(Revision, kind.capitalize + ' page ', 'title')
  end
  
  def title_from_name
    name = read_attribute(:name)
    name = nil if name.nil? || name.empty?
    name && name.underscore.gsub(/_/, ' ').capitalize
  end
  
  def sequence(finder, target, attr)
    result = target.strip
    suffix = 2
    while finder.find(:first, :conditions => "#{attr} = '#{result}'")
      result = target + suffix.to_s
      suffix += 1
    end
    return result    
  end
  
  def most_recent(attr)
    revisions.last && revisions.last.send(attr)  
  end
  
  def oldest(attr)
    revisions.first && revisions.first.send(attr)  
  end

  def clean(text)
    text.tr('ãàáâäÃÀÁÂÄèéêëÈÉÊËĩìíîïĨÌÍÎÏÿýÝŸõòóôöÕÒÓÔÖũùúûüŨÙÚÛÜñńÑŃćçÇĆśŕĺźŚŔĹŹ',
            'aaaaaAAAAAeeeeEEEEiiiiiIIIIIyyYYoooooOOOOOuuuuuUUUUUnnNNccCCsrlzSRLZ')
  end
  
  def drop_non_alpha(text)
    text.gsub(%r{[^a-zA-Z0-9]}, ' ').gsub(%r{\s+}, ' ')
  end
  
end

class PageReferenceCollector < MediaWikiLinkHandler
  def initialize(page)
    @referer = page
  end

  def url_for(page_name)
    page = Page.find_by_name(page_name)
    @referer.references << WikiReference.new(:referer => @referer,
                                             :referee => page) if page
    page_name
  end
end

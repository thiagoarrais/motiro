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

PLACE_HOLDER_TITLE = 'Insert page title here'

class Page < ActiveRecord::Base

  has_many :revisions, :order => 'modified_at DESC, id DESC'
  
  def original_author
    revisions.last && revisions.last.last_editor
  end
  
  %w{modified_at last_editor text editors title}.each do |attr|
    define_method attr do
      new_revision[attr.to_sym] || revisions.first && revisions.first.send(attr)
    end

    define_method(attr + '=') do |value|
      new_revision[attr.to_sym] = value
    end
  end

  def title
    result = new_revision[:title] || revisions.first && revisions.first.title
    return title_from_name || PLACE_HOLDER_TITLE.t if result.nil? || result.empty?
    return result
  end
  
  def after_initialize
    default('', :editors, :text, :name, :title)
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
      new_revision[:title] = title_from_kind  
    end
    
    unless new_revision.empty?
      revisions.unshift(Revision.new(new_revision))
    end
    
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
    new_revision.clear
    unless original_author || revisions.size == 0
      revisions.last.last_editor = author 
      revisions.last.save
    end
    rev = Revision.new(:last_editor => author, :modified_at => time)
    rev.editors = if author.can_change_editors?(self)
      attrs[:editors]
    else
      revisions.first.editors
    end
    self.kind = attrs[:kind] if attrs[:kind]
    rev.kind = self.kind
    rev.title, rev.text = attrs[:title], attrs[:text]
    self.revisions.unshift(rev)
    
    save
    self
  end
  
private
  
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
  
  def renderer
    @renderer ||= WikiRenderer.new
  end
  
private

  def clean(text)
    text.tr('ãàáâäÃÀÁÂÄèéêëÈÉÊËĩìíîïĨÌÍÎÏÿýÝŸõòóôöÕÒÓÔÖũùúûüŨÙÚÛÜñńÑŃćçÇĆśŕĺźŚŔĹŹ',
            'aaaaaAAAAAeeeeEEEEiiiiiIIIIIyyYYoooooOOOOOuuuuuUUUUUnnNNccCCsrlzSRLZ')
  end
  
  def drop_non_alpha(text)
    text.gsub(%r{[^a-zA-Z0-9]}, ' ').gsub(%r{\s+}, ' ')
  end
  
  def new_revision
    @new_revision ||= {}
  end
  
end

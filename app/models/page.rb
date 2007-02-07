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

  belongs_to :last_editor, :class_name => 'User',
                           :foreign_key => 'last_editor_id'
  belongs_to :original_author, :class_name => 'User',
                               :foreign_key => 'original_author_id'
  
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
      write_attribute(:title, title_from_kind)  
    end
    
    write_attribute(:name, self.name)
  end
  
  def name; name_before_type_cast; end
  def name_before_type_cast
    result = read_attribute(:name)
    return name_from_title if result.nil? || result.empty?
    return result
  end
  
  def title; title_before_type_cast; end
  def title_before_type_cast
    result = read_attribute(:title)
    return title_from_name || PLACE_HOLDER_TITLE.t if result.nil? || result.empty?
    return result
  end
  
  def use_parser(parser)
    @parser = parser
  end
  
  def is_open_to_all?
    0 == editors.strip.size
  end
  
private
  
  def name_from_title
    sequence(title.downcase.gsub(/ /, '_').camelize, 'name')
  end
  
  def title_from_kind
    sequence(kind.capitalize + ' page ', 'title')
  end
  
  def title_from_name
    name = read_attribute(:name)
    name = nil if name.nil? || name.empty?
    name && name.underscore.gsub(/_/, ' ').capitalize
  end
  
  def sequence(target, attr)
    result = target.strip
    suffix = 2
    while self.class.find(:first, :conditions => "#{attr} = '#{result}'")
      result = target + suffix.to_s
      suffix += 1
    end
    return result    
  end
  
  def renderer
    @renderer ||= WikiRenderer.new
  end
  
  def my_parser
    @parser ||= WikiParser.new
  end
  
end

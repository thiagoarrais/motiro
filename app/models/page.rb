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

require 'rubygems'
require 'mediacloth'

class Page < ActiveRecord::Base

  include MediaCloth
  
  belongs_to :original_author, :class_name => 'User',
                               :foreign_key => 'original_author_id'
  
  def after_initialize
    self.editors = '' unless self.editors
  end
  
  def render_html(locale_code=nil)
    translator = Translator.for(locale_code)
    wiki_text = translator.localize(text).delete("\r")
    wiki_to_html(wiki_text)
  end
  
  def use_parser(parser)
    @parser = parser
  end
  
  def is_open_to_all?
    0 == editors.strip.size
  end
  
private
  
  def my_parser
    @parser ||= WikiParser.new
  end
  
end

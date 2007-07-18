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
require 'diff/lcs'
require 'diff/lcs/array'

class WikiRenderer

  include MediaCloth

  def initialize(url_generator, locale_code=nil)
    @url_generator = url_generator
    @translator = Translator.for(locale_code)
  end
  
  def render_wiki_text(text)
    localized_text = @translator.localize(text).delete("\r")
    expanded_text = expand_internal_links(localized_text)
    wiki_to_html(expanded_text)
  end
  
  def render_wiki_diff(old_text, new_text)
    old_result = render_wiki_text(old_text).split    
    new_result = render_wiki_text(new_text).split
    diffsets = old_result.diff(new_result)

    diffsets.reverse.each do |dset|
      insertion_pt = nil
      removed_text = []
      inserted_text = []
      dset.each do |diff|
        if '-' == diff.action
          insertion_pt ||= diff.position
          removed_text << old_result.delete_at(insertion_pt) 
        else
          inserted_text << diff.element
        end
      end
      old_result.insert(insertion_pt,
        "<span class=\"deletion\">#{removed_text.join(' ')}</span>" +
        "<span class=\"addition\">#{inserted_text.join(' ')}</span>")
    end

    old_result.join(' ')
  end
  
  def expand_internal_links(text)
    text.gsub(/\[(\w+)([ \t]+([^\]]+))?\]/) do |substr|
      "[#{@url_generator.generate_url_for($1)} #{$2 ? $2: $1}]"
    end
  end

end
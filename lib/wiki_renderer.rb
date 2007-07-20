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

require 'string_extensions'
require 'array_extensions'

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
    old_result = render_wiki_text(old_text)    
    new_result = render_wiki_text(new_text)

    render_html_diff(old_result, new_result)
  end
  
  def render_html_diff(old_html, new_html)
    old_html, new_html = old_html.xml_split, new_html.xml_split
    diffsets = old_html.diff(new_html)

    diffsets.reverse.each do |dset|
      insertion_pt = nil
      removed_text = []
      inserted_text = []
      dset.each do |diff|
        insertion_pt ||= diff.position
        if '-' == diff.action
          removed_text << old_html.delete_at(insertion_pt) 
        else
          inserted_text << diff.element
        end
      end

      removed_text, inserted_text = removed_text.xml_join, inserted_text.xml_join
      match_old = removed_text.match(/<([^>])+(\s+[^>]+)?>(.*?)<\/\1>/)
      match_new = inserted_text.match(/<([^>])+(\s+[^>]+)?>(.*?)<\/\1>/)
      if match_old && match_new && match_old[1..2] == match_new[1..2]
        old_html.insert(insertion_pt,
                        [render_html_diff(match_old.pre_match, match_new.pre_match),
                         "<#{match_old[1..2].join}>",
                         render_html_diff(match_old[3], match_new[3]),
                         "</#{match_old[1]}>",
                         render_html_diff(match_old.post_match, match_new.post_match)].xml_join)
      else
        injection = ''
        injection += "<span class=\"deletion\">#{removed_text}</span>" unless removed_text.empty? 
        injection += "<span class=\"addition\">#{inserted_text}</span>" unless inserted_text.empty? 
        old_html.insert(insertion_pt, injection)
      end
    end

    old_html.xml_join
  end
  
  def expand_internal_links(text)
    text.gsub(/\[(\w+)([ \t]+([^\]]+))?\]/) do |substr|
      "[#{@url_generator.generate_url_for($1)} #{$2 ? $2: $1}]"
    end
  end

end
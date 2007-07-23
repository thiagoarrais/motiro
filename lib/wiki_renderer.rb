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

    HtmlDiffRenderer.new.render_html_diff(old_result, new_result)
  end

private

  def expand_internal_links(text)
    text.gsub(/\[(\w+)([ \t]+([^\]]+))?\]/) do |substr|
      "[#{@url_generator.generate_url_for($1)} #{$2 ? $2: $1}]"
    end
  end

end

class HtmlDiffRenderer

  def render_html_diff(old_html, new_html)
    @diff_words = @removed_text = @inserted_text = []
    Differ.new(self).diff(old_html.xml_split, new_html.xml_split)
  end
  
  def start_new_chunk(action)
    inject(@diff_words, @removed_text.xml_join, @inserted_text.xml_join)
    @removed_text = []
    @inserted_text = []
  end

  def store_diff(sdiff)
    if '=' == sdiff.action
      @diff_words << sdiff.old_element
    else
      @removed_text  << sdiff.old_element unless sdiff.old_element.nil?
      @inserted_text << sdiff.new_element unless sdiff.new_element.nil?
    end
  end

  def get_result
    inject(@diff_words, @removed_text.xml_join, @inserted_text.xml_join)
    
    @diff_words.xml_join
  end

private

  HTML_ELEMENT = /<([^>]+)(\s+[^>]+)?>(.*?)<\/\1>/m

  def inject(words, old_text, new_text)
    match_old = old_text.match(HTML_ELEMENT)
    match_new = new_text.match(HTML_ELEMENT)
    if match_old && match_new && match_old[1..2] == match_new[1..2]
      words << [HtmlDiffRenderer.new.render_html_diff(match_old.pre_match, match_new.pre_match),
                "<#{match_old[1..2].join}>",
                HtmlDiffRenderer.new.render_html_diff(match_old[3], match_new[3]),
                "</#{match_old[1]}>",
                HtmlDiffRenderer.new.render_html_diff(match_old.post_match, match_new.post_match)].xml_join
    else
      injection = ''
      injection += enclose('deletion', old_text) unless old_text.empty? 
      injection += enclose('addition', new_text) unless new_text.empty? 
      words << injection
    end
    words
  end
  
  def enclose(klass, text)
    return "<span class=\"#{klass}\">#{text}</span>" unless ?< == text[0]
    match = text.match(HTML_ELEMENT)
    [match.pre_match,
     "<#{match[1..2].join}><span class=\"#{klass}\">#{match[3]}</span></#{match[1]}>",
     match.post_match].xml_join
  end
end

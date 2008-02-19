#  Motiro - A project tracking tool
#  Copyright (C) 2006-2008  Thiago Arrais
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

  def initialize(url_generator, locale_code=nil)
    @html_generator = MediaWikiHTMLGenerator.new
    @translator = Translator.for(locale_code)
    @html_generator.link_handler = url_generator
  end
  
  def render_wiki_text(text)
    localized_text = @translator.localize(text).delete("\r")
    wiki_to_html(localized_text)
  end
  
  def render_wiki_diff(old_text, new_text)
    old_result = render_wiki_text(old_text)    
    new_result = render_wiki_text(new_text)

    HtmlDiffRenderer.new.render_html_diff(old_result, new_result)
  end

private

  def wiki_to_html(input)
    MediaCloth::wiki_to_html(input, :generator => @html_generator).
      gsub(/\r?\n?\r?\n<\//, '</').
      gsub('<p></p>', '')
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
    inject(@diff_words, @removed_text, @inserted_text)
    
    @diff_words.xml_join
  end

private

  HTML_ELEMENT = /<([^\s>]+)(\s+[^>]+)?>/

  def inject(words, old_words, new_words)
    old_words, new_words = group_words(old_words), group_words(new_words)
    old_words.fill(nil, old_words.size, new_words.size - old_words.size)
    pairs = old_words.zip(new_words)
    
    pairs.each do |pair|
      match_old = pair.first.match(HTML_ELEMENT) if pair.first
      match_new = pair.last.match(HTML_ELEMENT) if pair.last
      if match_old && match_new && match_old[1..2] == match_new[1..2]
        old_content, new_content = match_old.post_match, match_new.post_match
        old_content = old_content[0..(old_content.size - match_old[1].size - 4)]
        new_content = new_content[0..(new_content.size - match_new[1].size - 4)]
        words << ["<#{match_old[1..2].join}>",
                  HtmlDiffRenderer.new.render_html_diff(old_content, new_content),
                  "</#{match_old[1]}>"].xml_join
      else
        injection = ''
        injection += enclose('#ffb8b8', pair.first) if pair.first 
        injection += enclose('#b8ffb8', pair.last) if pair.last 
        words << injection
      end
    end
    words
  end
  
  def enclose(color, text)
    if (md = text.match(HTML_ELEMENT)) && md[0][-2..-1] != '/>'
      match = text.match(HTML_ELEMENT)
      text = match.post_match
      text = text[0..(text.size - match[1].size - 4)]

      "<#{match[1..2].join}><span style=\"background: #{color}\">#{text}</span></#{match[1]}>"
    else
      "<span style=\"background: #{color}\">#{text}</span>"
    end
  end
  
  def group_words(words)
    group = []
    words.each do |w|
      if group.empty? || ?< == w[0] || ?> == group.last[-1]
        group << w
      else
        group.last << ' ' << w
      end
    end
    group
  end
end

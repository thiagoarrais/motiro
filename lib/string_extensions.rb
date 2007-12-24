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

class String

  def medialize
    MediaCloth::wiki_to_html self
  end

  def xml_split
    remainder = self
    words = []
    while(md = remainder.match(/<([^>]+)(\s+[^>]+)?(>.*?<\/\1>|\/>)|[^\s<]+/m))
      word = md[0]
      remainder = md.post_match
      while word.match(/<\/#{md[1]}/) &&
            word.scan(/<#{md[1]}/).size > word.scan(/<\/#{md[1]}/).size
        m = remainder.match(/<\/#{md[1]}>/)
        word << m.pre_match << m[0]
        remainder = m.post_match
      end
      words << word
    end
    words
  end

end

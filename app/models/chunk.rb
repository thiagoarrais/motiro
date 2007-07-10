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

class Chunk
  attr_reader :lines, :action
  
  def initialize(action)
    @action = action
  end
  
  def unchanged?
    :unchanged == action
  end

  def <<(line)
    @lines ||= []
    @lines << line
  end
end

class Line
  attr_reader :original_text, :original_position,
              :modified_text, :modified_position
  
  def initialize(old_text, old_pos, new_text, new_pos)
    @original_text, @modified_text = old_text, new_text
    @original_position = old_text && old_pos
    @modified_position = new_text && new_pos
  end
end

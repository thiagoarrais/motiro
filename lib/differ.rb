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

require 'diff/lcs'
require 'diff/lcs/array'

Differ = Struct.new(:target)
class Differ

  def diff(old_elems, new_elems)
    sdiffs = old_elems.sdiff(new_elems)
    
    last_action = nil
    sdiffs.each do |sdiff|
      if chunk_break_needed(last_action, sdiff.action)
        target.start_new_chunk(sdiff.action)
      end
      last_action = sdiff.action
      
      target.store_diff(sdiff)
    end

    target.get_result
  end
  
private

  def chunk_break_needed(prev, curr)
    prev.nil? || curr != prev && [prev, curr].include?('=')
  end

end

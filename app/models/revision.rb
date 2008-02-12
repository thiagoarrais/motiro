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

class Revision < ActiveRecord::Base
  belongs_to :page
  belongs_to :last_editor, :class_name => 'User', :foreign_key => 'last_editor_id'

  #Delegate methods to parent page
  %w{name original_author revisions}.each do |method|
    define_method(method) { page.send(method) }
  end
  
  def diff(rev_num)
    ChunkDiffer.new.diff(text.split($/),
      #position numbers are 1-based, but we want 0-based when indexing revisions
                         page.revisions[rev_num - 1].text.split($/))
  end

end

class ChunkDiffer

  def diff(old_lines, new_lines)
    @chunks = []
    Differ.new(self).diff(old_lines, new_lines)
  end

  LCS_ACTION_TO_SYMBOL = {'=' => :unchanged, '!' => :modification,
                          '-' => :deletion, '+' => :addition}
  
  def start_new_chunk(action)
    @chunk = Chunk.new(LCS_ACTION_TO_SYMBOL[action])
    @chunks << @chunk
  end

  def store_diff(sdiff)
    #lcs's position are 0-based, but we want 1-based when rendering
    @chunk << Line.new(sdiff.old_element, sdiff.old_position + 1,
                       sdiff.new_element, sdiff.new_position + 1)
  end

  def get_result
    @chunks
  end

end

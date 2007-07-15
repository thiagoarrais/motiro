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

class Revision < ActiveRecord::Base
  belongs_to :page
  belongs_to :last_editor, :class_name => 'User', :foreign_key => 'last_editor_id'

  #Delegate methods to parent page
  %w{name original_author revisions}.each do |method|
    define_method(method) { page.send(method) }
  end
  
  LCS_ACTION_TO_SYMBOL = {'=' => :unchanged, '!' => :modification,
                          '-' => :deletion, '+' => :addition}
  
  def diff(rev_num)
    #position numbers are 1-based, but we want 0-based when indexing revisions
    sdiffs = text.split($/).sdiff(page.revisions[rev_num - 1].text.split($/))
    chunks = []
    last_action = chunk = nil
    sdiffs.each do |sdiff|
      if chunk_break_needed(last_action, sdiff.action) 
        chunk = Chunk.new(LCS_ACTION_TO_SYMBOL[sdiff.action])
        chunks << chunk
      end
      last_action = sdiff.action
      #lcs's position are 0-based, but we want 1-based when rendering
      chunk << Line.new(sdiff.old_element, sdiff.old_position + 1,
                        sdiff.new_element, sdiff.new_position + 1)
    end

    chunks
  end

private

  def chunk_break_needed(prev, curr)
    prev.nil? || curr != prev && [prev, curr].include?('=')
  end

end

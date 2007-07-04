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
  
  def diff(rev_num)
    #position numbers are 1-based, but we want 0-based when indexing revisions
    sdiffs = text.split($/).sdiff(page.revisions[rev_num - 1].text.split($/))
    chunks = []
    last_action = chunk = nil
    sdiffs.each do |sdiff|
      if chunk_break_needed(last_action, sdiff.action) 
        chunk = Chunk.new('=' == sdiff.action ? :unchanged : :modification)
        chunks << chunk
      end
      last_action = sdiff.action
      chunk << Line.new(sdiff.old_element, sdiff.new_element)
    end

    chunks
  end

private

  def chunk_break_needed(prev, curr)
    prev.nil? || curr != prev && [prev, curr].include?('=')
  end

end

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
  attr_reader :original_text, :modified_text
  
  def initialize(old_text, new_text)
    @original_text, @modified_text = old_text, new_text
  end
end
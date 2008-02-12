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

class DiffChunkBuilder

  def initialize
    @chunks = []
    @unmatched_deletions = []
    @old_line_num = @new_line_num = 1
    needs_new_chunk!
  end

  def start_line(old_line_num, new_line_num=old_line_num)
    consume_unmatched_deletions
    needs_new_chunk!
    @chunks << Separator.new(old_line_num - @old_line_num) unless @chunks.empty?
    @old_line_num, @new_line_num = old_line_num, new_line_num 
  end

  def push_deletion(text)
    @unmatched_deletions << [text, @old_line_num]
    @old_line_num += 1
  end
 
  def push_unchanged(text)
    consume_unmatched_deletions
    target_chunk_for(:unchanged) << Line.new(text, @old_line_num,
                                             text, @new_line_num)
    @old_line_num += 1
    @new_line_num += 1
  end

  def push_addition(text)
    unless @unmatched_deletions.empty?
      chunk = target_chunk_for(:modification)
      old_text, old_position = @unmatched_deletions.shift
      chunk << Line.new(old_text, old_position, text, @new_line_num)
    else
      target_chunk_for(:addition) << Line.new(nil, @old_line_num,
                                              text, @new_line_num)
    end
    @new_line_num += 1
  end

  def get_chunks
    consume_unmatched_deletions
    @chunks
  end

private

  def consume_unmatched_deletions
    return if @unmatched_deletions.empty?
    chunk = target_chunk_for(:deletion)
    @unmatched_deletions.each do |old_text, old_position|
      chunk << Line.new(old_text, old_position, nil, nil)
    end
    @unmatched_deletions = []
  end

  def needs_new_chunk!(need=true)
    @should_create_new_chunk = need
  end
  
  def needs_new_chunk?
    @should_create_new_chunk
  end

  ACCEPTABLE_PREVIOUS_ACTION = {:modification => [:modification],
                                :addition => [:addition, :modification],
                                :deletion => [:deletion, :modification],
                                :unchanged => [:unchanged]}

  def target_chunk_for(action)
    chunk = @chunks.last

    @chunks << chunk = Chunk.new(action) if needs_new_chunk? ||
      !ACCEPTABLE_PREVIOUS_ACTION[action].include?(chunk.action)

    needs_new_chunk!(false)
    chunk
  end

end

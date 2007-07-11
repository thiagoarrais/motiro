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

class Change < ActiveRecord::Base
  
  def chunked_diff
    return nil unless has_diff?
    return @chunked_diff if @chunked_diff
    @differ ||= DiffChunkBuilder.new
    diff.split("\n").each do |line|
      c = line[0,1]
      line_text = line[1, line.length - 1]
      
      if '+' == c then
        @differ.push_addition line_text
      elsif '-' == c then
        @differ.push_deletion line_text
      elsif ' ' == c then
        @differ.push_unchanged line_text
      elsif '@' == c then
        md = line_text.match(/-(\d+)[^\+]*\+(\d+)/)
        @differ.start_line(md[1].to_i, md[2].to_i)
      end
    end
    
    @chunked_diff = @differ.get_chunks
  end
  
  def to_s
    return summary
  end
  
  def qualified_resource_name
    return summary.match(/(\w )?([^\s]+)/)[2]
  end
  
  def resource_name
    return qualified_resource_name.split('/').last
  end
  
  def filled?
    self.resource_kind && ('dir' == self.resource_kind || has_diff?)
  end
  
  def has_diff?
    return ! (diff.nil? or diff.empty?)
  end
  
  def use_differ(differ)
    @differ = differ
  end
  
end

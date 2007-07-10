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

module ReportHelper

  def render_diff(change)
    return '' unless change.chunked_diff
    Builder::XmlMarkup.new.div(:id => "change" + change.summary.hash.to_s,
                               :class => "diff-window") do |b|
      b.h2 'Changes to %s' / change.resource_name
      b.table :class => 'diff', :cellspacing => '0' do
        change.chunked_diff.each do |chunk|
          b.tbody :class => chunk.action.to_s do
            chunk.lines.each do |line|
              b.tr :style => 'background: #FFF' do
                b.td(:class => 'line_number') {b << (line.original_position || '&nbsp;').to_s}
                b.td(:class => 'left' ) {b.pre{b << (h(line.original_text) || '&nbsp;')}}
                b.td(:class => 'right') {b.pre{b << (h(line.modified_text) || '&nbsp;')}}
                b.td(:class => 'line_number') {b << (line.modified_position || '&nbsp;').to_s}
              end
            end
          end
        end
      end
    end
  end

end

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

module ReportHelper

  def render_diff(change)
    return '' unless change.chunked_diff
    Builder::XmlMarkup.new.div(:id => ref(change),
                               :class => "diff-window") do |b|
      b.h2 'Changes to %s' / change.resource_name
      b << render_diff_table(change.chunked_diff)
    end
  end

  def render_summary(change)
    summary = html_escape(change.summary)
    if (change.has_diff?)
      "<a href='\#' onClick=\"showOnly('#{ref(change)}')\">#{summary}</a>"
    else
      summary
    end
  end

  def ref(change)
    "change" + change.summary.hash.to_s
  end
  
  def headline_link(headline)
    link_to( h(headline.title(Translator.for(@locale))),
             @reporter.params_for(headline.rid),
             page_link_handler.extra_link_attributes_for(headline.rid) )
  end

private

  def page_link_handler
    WikiLinkHandler.new(@controller)
  end

end

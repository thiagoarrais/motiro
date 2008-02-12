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

class WikiLinkHandler < MediaWikiLinkHandler

  def initialize(parent_controller)
    @parent_controller = parent_controller
  end
  
  def url_for(page_name)
    @parent_controller.server_url_for :controller => 'wiki', :action => 'show',
                                      :page_name => page_name
  end

  def link_attributes_for(page_name)
    atts = super(page_name)
    atts[:class] = 'done' if (page = Page.find_by_name(page_name)) && page.done?
    atts
  end

end

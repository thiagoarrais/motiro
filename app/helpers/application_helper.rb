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

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def current_user
    session[:user] || NullUser.new
  end
  
  def current_locale
    @locale
  end
  
  def server_url_for(options = {})
    url_for options.update(:only_path => false)
  end
  
  def dynjs_include_tag(script_name)
    content_tag("script", "", { "type" => "text/javascript",
                                "src" => url_for(:controller => 'javascript',
                                                 :action => script_name) })
  end
  
  def pagetext(title, &block)
    content = capture(&block)
    b = Builder::XmlMarkup.new
    xml = b.div(:class => 'pagetext') do
      b.div(:id => 'crumbs') do
         b.text!('You are here: '.t)
         last = @crumbs.delete_at(@crumbs.length - 1)
         @crumbs.each do |h|
           b.a(h.keys.first,
               :href => url_for(h.values.first.update(:only_path => true)))
           b << ' > '
         end
         b.a(last.keys.first,
             :href => url_for(last.values.first.update(:only_path => true)))
      end
      b.h1(title)
      b << content
    end
    concat(xml, block.binding)
  end

end

class NullUser

  def nil?; true; end
  def can_edit?(p); false; end
  def can_change_editors?(p); false; end
  
end

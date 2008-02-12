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

module ActionController::Routing
  class MotiroSegment < DynamicSegment
    def match_extraction(next_capture)
      "imatch = match[#{next_capture}].match(/-/)\n" +
      "params[:page_name] = imatch ? imatch.pre_match : match[#{next_capture}]\n" +
      "params[:locale] = imatch.post_match unless imatch.nil?"
    end
    
    def extraction_code
      s =   "page_name_value = hash[:page_name] && hash[:page_name].clone"
      s << "\nreturn [nil, nil] if page_name_value.nil?"
      s << "\n#{expiry_statement}"

      s << "\nlocale_value = hash[:locale]"
      s << "\noptions.delete(:locale)"
      s << "\nexpired, hash = true, options if !expired && expire_on[:locale]"
      s << "\npage_name_value << '-' << locale_value unless locale_value.nil?"
    end
  end

  class MotiroRouteBuilder < RouteBuilder
    def segment_for(string)
      if string.match(/\A:page_name/)
        [MotiroSegment.new(:page_name), $~.post_match]
      else
        super
      end
    end
  end

  class RouteSet
    def builder
      @builder ||= MotiroRouteBuilder.new
    end
  end
end

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

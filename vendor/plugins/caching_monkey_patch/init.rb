module ActionController::Caching::Pages
  def cache_page(content = nil, options = params)
    return unless perform_caching && caching_allowed

    if options.is_a?(Hash)
      path = url_for(options.merge(:only_path => true, :skip_relative_url_root => true, :format => params[:format]))
    else
      path = options
    end

    self.class.cache_page(content || response.body, path)
  end
end

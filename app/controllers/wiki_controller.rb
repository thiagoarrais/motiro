class WikiController < ApplicationController

    before_filter :login_required
    
    def protect?(action)
        return false if 'show' == action
        return true    
    end
    
    def initialize(page_provider=Page)
        @page_provider = page_provider
    end
    
    def edit
        @page = find_page(params[:page])
    end
    
    def show
        @page = find_page(params[:page])
        if params[:locale] then
          @rendered_page = @page.render_html(params[:locale])
        else
          @rendered_page = @page.render_html
        end
    end
    
    def save
        page = find_page(params[:page][:name])
        page.text = params[:page][:text]
        page.save
        redirect_to(:controller => 'root', :action => 'index')
    end
    
private

    def find_page(name)
        @page_provider.find_by_name(name) || default_page(name)
    end
    
    def default_page(name)
        page = Page.new(:name => name)
        page.text = WIKI_NOT_FOUND_TEXT
        return page
    end

end

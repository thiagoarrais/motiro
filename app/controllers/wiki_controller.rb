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
    end
    
    def save
        page = find_page(params[:page][:name])
        page.text = params[:page][:text]
        page.save
        redirect_to(:controller => 'root', :action => 'index')
    end
    
private

    def find_page(name)
        @page_provider.find_by_name(name)
    end

end

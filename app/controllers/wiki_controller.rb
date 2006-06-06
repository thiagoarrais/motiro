class WikiController < ApplicationController

    def initialize(page_provider=Page)
        @page_provider = page_provider
    end
    
    def edit
        @page_text = @page_provider.find_by_name(params[:page]).text
    end

end

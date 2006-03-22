require 'models/headline'

require 'core/chief_editor'

class ReportController < ApplicationController

    def initialize
        @chief_editor = ChiefEditor.new
    end

    def show
        if params[:id]
            id = params[:id]
            @headline = Headline.find(id)
            
            render(:action => 'detail')
        else
            reporter = params[:reporter]
            format = params[:format] || 'html_fragment'
        
            @headlines = @chief_editor.latest_news_from reporter
            render(:action => format)
        end
    end
    
end

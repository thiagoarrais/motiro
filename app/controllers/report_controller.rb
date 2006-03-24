require 'models/headline'

require 'core/chief_editor'

class ReportController < ApplicationController

    def initialize(chief_editor=ChiefEditor.new)
        @chief_editor = chief_editor
    end

    def show
        reporter = params[:reporter]

        if params[:id]
            id = params[:id]
            @article = @chief_editor.article_for_headline(reporter, id)
            
            render(:action => 'detail')
        else
            format = params[:format] || 'html_fragment'
        
            @headlines = @chief_editor.latest_news_from reporter
            render(:action => format)
        end
    end
    
end

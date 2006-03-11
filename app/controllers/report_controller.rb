require 'models/headline'

require 'core/chief_editor'

class ReportController < ApplicationController

    def initialize
        @chief_editor = ChiefEditor.new
    end

    def show
        reporter = params[:reporter]
        format = params[:format] || 'html_fragment'
        
        @headlines = @chief_editor.latest_news_from reporter
        render(:action => format)
    end
    
end

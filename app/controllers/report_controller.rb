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
            context = params[:context] || 'full'
            begin
                @revision_id = id
                @article = @chief_editor.article_for_headline(reporter, id)
                @partial = context == 'partial'
                
                render(:action => 'detail')
            rescue
                logger.error("Tried to access invalid headline #{id} from #{reporter}")
                flash[:notice] = "Não foi possível encontrar o artigo #{id} do repórter #{reporter.capitalize}"
                redirect_to(:controller => 'root', :action => 'index')
            end            
        else
            format = params[:format] || 'html_fragment'
        
            @headlines = @chief_editor.latest_news_from reporter
            render(:action => format)
        end
    end
    
end

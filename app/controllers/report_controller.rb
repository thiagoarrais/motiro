require 'models/headline'

require 'core/chief_editor'

class ReportController < ApplicationController

    def initialize(chief_editor=ChiefEditor.new)
        @chief_editor = chief_editor
    end

    def show
        reporter_name = params[:reporter]

        if params[:id]
            id = params[:id]
            context = params[:context] || 'full'
            begin
                @revision_id = id
                @article = @chief_editor.article_for_headline(reporter_name, id)
                @partial = context == 'partial'
                
                render(:action => 'detail')
            rescue
                logger.error("Tried to access invalid headline #{id} from #{reporter_name}")
                flash[:notice] = "Não foi possível encontrar o artigo #{id} do repórter #{reporter_name.capitalize}"
                redirect_to(:controller => 'root', :action => 'index')
            end            
        else
            format = params[:format] || 'html_fragment'
            
            @name = reporter_name
            @title = @chief_editor.title_for reporter_name
            @headlines = @chief_editor.latest_news_from reporter_name
            render(:action => format)
        end
    end
    
end

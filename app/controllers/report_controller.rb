require 'models/headline'

require 'core/chief_editor'

class ReportController < ApplicationController
  
  layout :determine_layout
  
  before_filter do |me|
    me.instance_eval do
      @name = params[:reporter]
    end
  end

  before_filter(:only => [:rss, :list]) do |me|
    me.instance_eval do
      @headlines = @chief_editor.latest_news_from @name
    end
  end
  
  def initialize(chief_editor=ChiefEditor.new)
    @chief_editor = chief_editor
  end
  
  def determine_layout
    return 'application' if params[:id] and params[:context] != 'partial'
    return nil
  end
  
  def rss; end
  
  def list
    @title = @chief_editor.title_for @name
    @toolbar = @chief_editor.toolbar_for @name
  end
  
  def show
    id = params[:id]
    context = params[:context] || 'full'
    
    begin
      @revision_id = id
      @headline = @chief_editor.headline_with(@name, id)
      @partial = context == 'partial'
      
      render(:action => "#{@name}_detail")
    rescue
      logger.error("Tried to access invalid headline #{id} from #{@name}")
      flash[:notice] = 'The article %s from the %s reporter could not be found' / id / @name.capitalize
      redirect_to(:controller => 'root', :action => 'index')
    end            
  end
  
end

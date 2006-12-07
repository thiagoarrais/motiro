require 'reporters/events_reporter'

class EventsController < EditionController

  before_filter :login_required

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :controller => 'root', :action => 'index' }

  def initialize(reporter=EventsReporter.new)
    @reporter = reporter
  end

  def new
    @headline = Headline.new
    render :layout =>  'wiki_edit'
  end

  def do_save  
    attrs = params[:headline]
    attrs[:author] = session[:user].login
    
    flash[:notice] = 'Event added'.t if @reporter.store_event(attrs)
    redirect_to :controller => 'root', :action => 'index'
  end

end

class EventsController < ApplicationController

  before_filter :login_required

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def new
    @headline = Headline.new
  end

  def create
    #TODO refactor
    h = params[:headline]
    @headline = Headline.new(:title => h['title'],
                             :author => session[:user].login,
                             :happened_at => [h['happened_at(1i)'].to_i,
                                              h['happened_at(2i)'].to_i,
                                              h['happened_at(3i)'].to_i ],
                             :reported_by => 'events',
                             :description => h['description'])
    if @headline.save
      flash[:notice] = 'Evento registrado.'
      redirect_to :controller => 'root', :action => 'index'
    else
      render :action => 'new'
    end
  end

  def update
    @headline = Headline.find(params[:id])
    if @headline.update_attributes(params[:rasta])
      flash[:notice] = 'Evento modificado.'
      redirect_to :action => 'show', :id => @headline
    else
      render :action => 'edit'
    end
  end

  def destroy
    Headline.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end

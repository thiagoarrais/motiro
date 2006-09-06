class WikiController < EditionController

  layout nil

  before_filter :login_required
  before_filter :check_edit_access, :only => [:edit, :save]
    
  def protect?(action)
    return false if 'show' == action
    return true    
  end
    
  def initialize(page_provider=Page)
    @page_provider = page_provider
  end
  
  def check_edit_access
    @page = find_page(params[:page_name])
    unless current_user.can_edit?(@page)
      flash[:not_authorized] = true
      redirect_to :action => 'show', :page_name => @page.name
      return false
    end
    
    return true
  end
    
  def edit
    render(:layout => 'wiki_edit')
  end
    
  def do_save
    @page.original_author ||= current_user
    @page.attributes = params[:page]
    @page.save
    if 'MainPage' == @page.name
      redirect_to :controller => 'root', :action => 'index'
    else
      redirect_to :action => 'show', :page_name => @page.name
    end
  end
  
  def show
    @page = find_page(params[:page_name])
    @rendered_page = @page.render_html(params[:locale])
  end
    
  #TODO show prettier page when /wiki/show/PageName
    
private

  def find_page(name)
    @page_provider.find_by_name(name) || default_page(name)
  end
    
  def default_page(name)
    page = Page.new(:name => name)
    page.text = WIKI_NOT_FOUND_TEXT
    return page
  end

end

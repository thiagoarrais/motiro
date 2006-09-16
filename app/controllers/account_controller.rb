class AccountController < ApplicationController
  layout  'scaffold'
  
  verify :method => :post, :only => [:signup],
         :redirect_to => {:controller => 'root', :action => 'index'}

  def login
    case request.method
      when :post
      if session[:user] = User.authenticate( params[:user][:login],
                                             params[:user][:password] )

        flash['notice']  = "Login successful"
        redirect_back_or_default params[:return_to]
      else
        flash.now['notice']  = "Login unsuccessful"

        @login = @params[:user_login]
      end
    end
  end
  
  def signup
    user = User.new(params[:user])
      
    if user.save
      session[:user] = User.authenticate( params[:user][:login],
                                          params[:user][:password] )

    else
      flash[:desired_login] = params[:user][:login]
    end

    redirect_back_or_default params[:return_to]
  end
  
  def availability
    @not_available = ! User.find_by_login(params[:desired_login]).nil?
    
    render :template => 'layouts/_auth_errors', :layout => false
  end
  
  def logout
    session[:user] = nil
  end
    
  def welcome
  end
  
end

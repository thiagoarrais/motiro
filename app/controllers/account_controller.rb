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
    if User.find_by_login(params[:user][:login])
    
      flash[:username_used] = params[:user][:login]
      
      redirect_back_or_default params[:return_to]
    else
      user = User.new(params[:user])
        
      if user.save
        session[:user] = User.authenticate( params[:user][:login],
                                            params[:user][:password] )
  
      end
  
      redirect_back_or_default params[:return_to]
    end
  end
  
  def logout
    session[:user] = nil
  end
    
  def welcome
  end
  
end

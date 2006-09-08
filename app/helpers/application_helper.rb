# Methods added to this helper will be available to all templates in the application.
class NullUser

  def nil?; true; end
  def can_edit?(p); false; end
  def can_change_editors?(p); false; end
  
end

module ApplicationHelper

  def current_user
    session[:user] || NullUser.new
  end
  
  def server_url_for(options = {})
    url_for options.update(:only_path => false)
  end


end

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def server_url_for(options = {})
    url_for options.update(:only_path => false)
  end


end

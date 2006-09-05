module WikiHelper

  def original_author_is_editing
    @page.original_author.nil? || session[:user] == @page.original_author
  end

end

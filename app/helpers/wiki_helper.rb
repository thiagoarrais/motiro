module WikiHelper

  def original_author_is_editing
    @page.original_author.nil? || current_user == @page.original_author
  end

end

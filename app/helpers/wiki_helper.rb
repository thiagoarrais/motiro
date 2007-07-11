module WikiHelper

  def page_history_link(page)
    case page.revisions.size
      when 0 then ''
      when 1 then '| ' + 'Page has no history yet'.t
      else '| ' + link_to('Page history (%s revisions)'/page.revisions.size.to_s,
                          :controller => 'wiki', :action => 'history',
                          :page_name => page.name)
    end
  end

end

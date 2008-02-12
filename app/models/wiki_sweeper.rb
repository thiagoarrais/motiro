#  Motiro - A project tracking tool
#  Copyright (C) 2006-2008  Thiago Arrais
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

class WikiSweeper < ActionController::Caching::Sweeper

  observe Page
  
  def after_save(page)
    expire_referers(page) if page.revisions.size > 1 &&
                             page.revisions[-1].done != page.revisions[-2].done

    expire_fragment(fragments_for(page))
    cache_dir = ActionController::Base.page_cache_directory
    FileUtils.rm_r(Dir.glob(cache_dir+"/wiki/history/#{page.name}*")) rescue Errno::ENOENT
  end

private

  def expire_referers(page)
    page.refering_pages.each do |referer|
      expire_fragment(fragments_for(referer))
    end
  end

  def fragments_for(page)
    /wiki\/show.*?#{page.name}/
  end
end


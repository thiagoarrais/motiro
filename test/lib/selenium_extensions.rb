#  Motiro - A project tracking tool
#  Copyright (C) 2006-2007  Thiago Arrais
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

module SeleniumExtensions

  def wait_for_visible(elem_id)
    wait_for_condition(visible(elem_id), 2000)
  end

  def wait_for_not_visible(elem_id)
    wait_for_condition("! " + visible(elem_id), 2000)
  end
  
  def visible(elem_id)
    "selenium.browserbot.getCurrentWindow().document.getElementById('#{elem_id}').style.display != 'none'"  
  end

end
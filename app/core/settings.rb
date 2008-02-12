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

require 'yaml'

# The settings provider is responsible for reading the settings from the
# config file and providing them to clients
class SettingsProvider
  
  def initialize(fs=File)
    @filesystem = fs
  end
  
  def method_missing(method_id)
    load_confs[method_id.to_s].to_i
  end
  
  def active_reporter_ids
    load_confs.keys - ['package_size', 'update_interval']
  end
  
private

  def load_confs
    file = @filesystem.open(File.expand_path(RAILS_ROOT + '/config/motiro.yml'))
    confs = YAML.load file
  end
  
end

require 'core/settings'

class DarcsSettingsProvider < SettingsProvider
    
  def repo_url
    load_confs['darcs']['repo']
  end
    
end
require 'core/settings'

class SubversionSettingsProvider < SettingsProvider
    
  def repo_url
    load_confs['subversion']['repo']
  end
    
end
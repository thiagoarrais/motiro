require 'core/settings'

class SubversionSettingsProvider < SettingsProvider
    
  def repo_url
    load_confs['svn']['repo']
  end
    
end
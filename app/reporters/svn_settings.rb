require 'core/settings'

class SubversionSettingsProvider < SettingsProvider
    
    def getRepoURL
        return load_confs['svn']['repo']
    end
    
end
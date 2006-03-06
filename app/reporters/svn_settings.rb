require 'yaml'

require 'core/filesystem'

class SubversionSettingsProvider
    
    # The settings provider is responsible for reading the settings from the
    # config file and providing them to clients

    def initialize(fs=FileSystem.new)
        @filesystem = fs
    end

    #TODO parametize the repo location
    def getRepoURL
        file = @filesystem.open(File.expand_path(File.dirname(__FILE__) +
                                '/../../config/report/subversion.yml'))
        confs = YAML.load file
        return confs['repo']
    end
    
end
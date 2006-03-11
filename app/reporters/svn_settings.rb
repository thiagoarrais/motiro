require 'yaml'

require 'ports/filesystem'

class SubversionSettingsProvider
    
    # The settings provider is responsible for reading the settings from the
    # config file and providing them to clients

    def initialize(fs=FileSystem.new)
        @filesystem = fs
    end

    def getRepoURL
        file = @filesystem.open(File.expand_path(File.dirname(__FILE__) +
                                '/../../config/report/subversion.yml'))
        confs = YAML.load file
        return confs['repo']
    end
    
    def getPackageSize
        file = @filesystem.open(File.expand_path(File.dirname(__FILE__) +
                                '/../../config/report/subversion.yml'))
        confs = YAML.load file
        return confs['package_size'].to_i
    end
    
end
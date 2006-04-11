require 'yaml'

require 'ports/filesystem'

class SubversionSettingsProvider
    
    # The settings provider is responsible for reading the settings from the
    # config file and providing them to clients

    def initialize(fs=FileSystem.new)
        @filesystem = fs
    end

    def getRepoURL
        return load_confs['svn']['repo']
    end
    
    def getPackageSize
        return load_confs['package_size'].to_i
    end
    
    def getUpdateInterval
        return load_confs['update_interval'].to_i
    end
    
private
    def load_confs
        file = @filesystem.open(File.expand_path(File.dirname(__FILE__) +
                                '/../../config/report/subversion.yml'))
        confs = YAML.load file
    end
    
end
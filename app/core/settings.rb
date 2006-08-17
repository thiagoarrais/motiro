require 'yaml'

require 'ports/filesystem'

class SettingsProvider
    
    # The settings provider is responsible for reading the settings from the
    # config file and providing them to clients

    def initialize(fs=FileSystem.new)
        @filesystem = fs
    end

    def getPackageSize
        return load_confs['package_size'].to_i
    end
    
    def getUpdateInterval
        return load_confs['update_interval'].to_i
    end
    
    def active_reporter_ids
      load_confs.keys - ['package_size', 'update_interval']
    end
    
private
    def load_confs
        file = @filesystem.open(File.expand_path(File.dirname(__FILE__) +
                                '/../../config/motiro.yml'))
        confs = YAML.load file
    end
    
end
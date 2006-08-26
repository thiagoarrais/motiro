require 'yaml'

class SettingsProvider
    
    # The settings provider is responsible for reading the settings from the
    # config file and providing them to clients

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
        file = @filesystem.open(File.expand_path(File.dirname(__FILE__) +
                                '/../../config/motiro.yml'))
        confs = YAML.load file
    end
    
end
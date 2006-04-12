require 'yaml'

class Configuration

    FILE_NAME = File.expand_path(File.dirname(__FILE__) +
                             '/../../config/motiro.yml')

    def initialize
        @original_contents = File.open(FILE_NAME).read
        @confs = YAML.load @original_contents
    end

    def update_interval=(new_interval)
        reconfigure('update_interval', new_interval)
    end
    
    def repo=(new_url)
        reconfigure('svn/repo', new_url)
    end
    
    def go_live
        self.update_interval = 0
    end
    
    def go_cached
        self.update_interval = 10
    end
    
    def revert
        file = File.open(FILE_NAME, 'w')
        file << @original_contents
        file.close
    end
    
private

    def reconfigure(key, value)
        dst_hash = @confs
        keys = key.split('/')
        last_key = keys.pop
        keys.each do |k|
            dst_hash = dst_hash[k]
        end
        
        dst_hash[last_key] = value
        file = File.open(FILE_NAME, 'w')
        YAML.dump(@confs, file)
        file.close
    end
    
end
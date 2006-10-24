require 'socket'

# Utilities for local repositories
module NetUtils

  def self.find_available_port
    port = 36906
    while(try_port(port))
      port += 1
    end
        
    return port
  end
    
  def self.try_port(port)
    begin
      t = TCPSocket.new('localhost', port)
      t.close
      return true
    rescue
      return false
    end
  end
  
end
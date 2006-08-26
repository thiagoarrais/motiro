require 'socket'

# Utilities for local repositories
module RepoUtils

  def find_root_dir(prefix='svn')
    tmpdir = ENV['TEMP']
    return find_free_dir_under(tmpdir, prefix)
  end

  def find_free_dir_under(parent_dir, prefix)
    contents = Dir.entries(parent_dir)
    suffix = ''
    if (contents.include?(prefix))
      suffix = 1
      while(contents.include?(prefix + suffix.to_s))
        suffix += 1
      end
    end

    return parent_dir + '/' + prefix + suffix.to_s
  end

  def find_available_port
    port = 36906
    while(try_port(port))
      port += 1
    end
        
    return port
  end
    
  def try_port(port)
    begin
      t = TCPSocket.new('localhost', port)
      t.close
      return true
    rescue
      return false
    end
  end
  
end
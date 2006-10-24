require 'webrick'
require 'webrick/https'

require 'netutils'

module WebServer

  def self.create_https_server
    create_server(
      :SSLEnable       => true,
      :SSLVerifyClient => ::OpenSSL::SSL::VERIFY_NONE,
      :SSLCertName => [ ["C","JP"], ["O","WEBrick.Org"], ["CN", "WWW"] ] )
  end
  
  def self.create_http_server_on(document_root)
    create_server :DocumentRoot => document_root
  end
  
  def self.create_server(options)
    defaults = { :Port => NetUtils.find_available_port,
                 :DocumentRoot    => Dir::pwd,
                 :Logger => NullLogger.new,
                 :AccessLog => [ [NullLogger.new, WEBrick::AccessLog::COMBINED_LOG_FORMAT] ] }

    server = WEBrick::HTTPServer.new defaults.update(options)

    Thread.new do
      server.start
    end
    
    return server
  end

end

class NullLogger
  def method_missing(name, *args); end
end

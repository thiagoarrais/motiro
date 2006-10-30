#  Motiro - A project tracking tool
#  Copyright (C) 2006  Thiago Arrais
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

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

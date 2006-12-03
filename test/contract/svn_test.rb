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

require File.dirname(__FILE__) + '/../test_helper'

require 'platform'
require 'popen4'

require 'webserver'

# What we expect from the `svn' command line client
class SubversionTest < Test::Unit::TestCase

  def setup
    @server = WebServer.create_https_server
  end
  
  def test_accept_certificate_temporarily
    ENV['LC_MESSAGES'] = 'C'
    POpen4.popen4("svn log https://localhost:#{@server[:Port]}") do |_, err, sin|
      sin.puts 't'
      sin.close
      
      9.times do
        err.gets
      end

      assert err.read(30) =~ /\(t\)/
    end
  end
  
  def teardown
    @server.shutdown
  end
  
end

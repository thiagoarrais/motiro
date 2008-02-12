#  Motiro - A project tracking tool
#  Copyright (C) 2006-2008  Thiago Arrais
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

require 'rubygems'
require 'rails-installer'

#  motiro-installer.rb includes some patches to rails-app-installer that
#  make it work on most win32 environments
module Kernel
  def sistem(cmd)
    system("echo | #{cmd}")
  end
end

class RailsInstaller

  def pre_migrate_database
    old_schema_version = get_schema_version
    new_schema_version = File.read(File.join(source_directory,'db','schema_version')).to_i
    
    return unless old_schema_version > 0
     
    # Are we downgrading?
    if old_schema_version > new_schema_version
      message "Downgrading schema from #{old_schema_version} to #{new_schema_version}"
      
      in_directory install_directory do
        unless sistem("rake -s migrate VERSION=#{new_schema_version}")
          raise InstallFailed, "Downgrade migrating from #{old_schema_version} to #{new_schema_version} failed."
        end
      end
    end
  end

  def migrate
    message "Migrating #{@@app_name.capitalize}'s database to newest release"
    
    in_directory install_directory do
      unless sistem("rake -s migrate")
        raise InstallFailed, "Migration failed"
      end
    end
  end

  def system_silently(command)
    if RUBY_PLATFORM =~ /mswin32/
      null = 'NUL:'
    else
      null = '/dev/null'
    end
    
    sistem("#{command} > #{null} 2> #{null}")
  end

  class Database
    class Postgresql < RailsInstaller::Database
      def self.create_database(installer)
        installer.message "Creating PostgreSQL database"
        sistem("createdb -U #{db_user installer} #{db_name installer}")
        sistem("createdb -U #{db_user installer} #{db_name installer}-test")
      end
    end

    class Mysql < RailsInstaller::Database
      def self.create_database(installer)
        installer.message "Creating MySQL database"
        base_command = "mysql -u #{db_user installer} "
        base_command << "-p#{installer.config['db_password']}" if installer.config['db_password']
        sistem("#{base_command} -e 'create database #{db_name installer}'")
        sistem("#{base_command} -e 'create database #{db_name installer}_test'")
      end
    end
  end

  class WebServer
    class Mongrel < RailsInstaller::WebServer
      def self.start(installer, foreground)
        args = {}
        args['-p'] = installer.config['port-number']
        args['-a'] = installer.config['bind-address']
        args['-e'] = installer.config['rails-environment']
        args['-d'] = foreground
        args['-P'] = pid_file(installer)
        args['--prefix'] = installer.config['url-prefix']

        # Remove keys with nil values
        args.delete_if {|k,v| v==nil}

        args_array = args.to_a.flatten.map {|e| e.to_s}
        args_array = ['mongrel_rails', 'start', installer.install_directory] + args_array
        installer.message "Starting #{installer.app_name.capitalize} on port #{installer.config['port-number']}"
        in_directory installer.install_directory do
          sistem(args_array.join(' '))
        end
      end

      def self.stop(installer)
        args = {}
        args['-P'] = pid_file(installer)

        args_array = args.to_a.flatten.map {|e| e.to_s}
        args_array = ['mongrel_rails', 'stop', installer.install_directory] + args_array
        installer.message "Stopping #{installer.app_name.capitalize}"
        in_directory installer.install_directory do
          sistem(args_array.join(' '))
        end
        
      end
    end

    class MongrelCluster < RailsInstaller::WebServer
      def self.start(installer, foreground)
        args = {}
        args['-p'] = installer.config['port-number']
        args['-a'] = installer.config['bind-address']
        args['-e'] = installer.config['rails-environment']
        args['-N'] = installer.config['threads']
        args['--prefix'] = installer.config['url-prefix']

        # Remove keys with nil values
        args.delete_if {|k,v| v==nil}

        args_array = args.to_a.flatten.map {|e| e.to_s}
        args_array = ['mongrel_rails', 'cluster::configure'] + args_array
        installer.message "Configuring mongrel_cluster for #{installer.app_name.capitalize}"
        in_directory installer.install_directory do
          sistem(args_array.join(' '))
        end
        installer.message "Starting #{installer.app_name.capitalize} on port #{installer.config['port-number']}"
        in_directory installer.install_directory do
          sistem('mongrel_rails cluster::start')
        end
        
      end
  
      def self.stop(installer)
        installer.message "Stopping #{installer.app_name.capitalize}"
        in_directory installer.install_directory do
          sistem('mongrel_rails cluster::stop')
        end
      end
    end
  end

end
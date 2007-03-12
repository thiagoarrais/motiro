#  packaging.rake largely inspired by Tobias Luetke's release.rake for typo
#
#  Motiro - A project tracking tool
#  Copyright (C) 2006-2007  Thiago Arrais
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

require File.expand_path(File.dirname(__FILE__) + '/../../app/core/version')

unless MOTIRO_VERSION.include? 'dev'

  require 'rake/gempackagetask'

  PKG_NAME = 'motiro'

  spec = Gem::Specification.new do |s|
    s.name = PKG_NAME
    s.version = MOTIRO_VERSION
    s.summary = "Simple project tracking tool"
    s.has_rdoc = false

    s.files = Dir.glob('**/*', File::FNM_DOTMATCH).reject do |f| 
      [ /\.$/, /database\.sqlite/, /^(tmp|log)/, /(^|\/)\./,
        /\.log$/, /^pkg/, /\.svn/, /^vendor\//, 
        /\~$/, /motiro(db|test)\.sqlite$/,
        /^db\/(development_structure\.sql|schema.rb)/,
        %r{public/javascript($|/)},
        /\/\._/, /\/#/ ].any? {|regex| f =~ regex }
    end
    s.files += Dir.glob('vendor/plugins/**/*') <<
               'log/.keepdir' << 'vendor/motiro-installer.rb'
    s.require_path = '.'
    s.author = "Thiago Arrais"
    s.email = "thiago.arrais@gmail.com"
    s.homepage = "http://www.motiro.org"  
    s.rubyforge_project = "motiro"
    s.platform = Gem::Platform::RUBY 
    s.executables = ['motiro']

    s.add_dependency("rails", "= 1.2.2")
    s.add_dependency("mediacloth", ">= 0.0.2")
    s.add_dependency("daemons", ">= 1.0.4")
    s.add_dependency("Platform", ">= 0.4.0")
    s.add_dependency("open4", ">= 0.9.1")
    s.add_dependency("POpen4", ">= 0.1.1")
    s.add_dependency("sqlite3-ruby", ">= 1.2.1")
    s.add_dependency("flexmock", ">= 0.5")
    s.add_dependency("rails-app-installer", "= 0.2.0")
  end

  packaging = Rake::GemPackageTask.new(spec) do |p|
    p.gem_spec = spec
  end
  
  task :tarball => packaging.package_dir_path do
    files = Dir.glob('vendor/**/*').reject do |f|
      f =~ %r{^vendor/plugins}
    end
	
    files.each do |fn|
      f = File.join(packaging.package_dir_path, fn)
      fdir = File.dirname(f)
      mkdir_p(fdir) if !File.exist?(fdir)
      if File.directory?(fn)
        mkdir_p(f)
      else
        rm_f f
        safe_ln(fn, f)
      end
    end
	
    safe_ln(File.join(packaging.package_dir_path, 'db/motirodb.sqlite.initial'),
            File.join(packaging.package_dir_path, 'db/motirodb.sqlite'))
    rm_f(File.join(packaging.package_dir_path, 'db/motirodb.sqlite.initial'))
    
    chdir(packaging.package_dir) do
	  sh %{tar cvzf #{packaging.package_name}.tar.gz #{packaging.package_name}}
	end
  end

end

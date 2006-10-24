# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/switchtower.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

require(File.join(File.dirname(__FILE__), 'app', 'core', 'version'))

task :dist_tarball => [:test_units, :test_functional] do
    parentdir = File.expand_path(File.dirname(__FILE__) + '/..')
    `tar cvzf motiro-#{MOTIRO_VERSION}.tar.gz  .`
end

namespace :test do
  desc "Run the functional tests in test/contract"
  Rake::TestTask.new(:contracts) do |t|
    t.libs << "test"
    t.pattern = 'test/contract/**/*_test.rb'
    t.verbose = true
  end
end

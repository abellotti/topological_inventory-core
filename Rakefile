begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'TopologicalInventory'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

load 'rails/tasks/statistics.rake'

require 'bundler/gem_tasks'
require "rspec/core/rake_task"

require "active_record"
require "yaml"

load "active_record/railties/databases.rake"

namespace :db do
  task :environment => :prepare_active_record do
    ActiveRecord::Base.establish_connection(ENV["RAILS_ENV"].to_sym)
  end

  task :prepare_active_record do
    ENV["RAILS_ENV"] ||= "development"

    root = Pathname.new(__dir__)
    database_yaml_path = root.join("config", "database.yml")
    database_yaml = YAML.load_file(database_yaml_path) if database_yaml_path.exist?

    ActiveRecord::Tasks::DatabaseTasks.env = ENV["RAILS_ENV"]
    ActiveRecord::Tasks::DatabaseTasks.database_configuration = database_yaml || {}
    ActiveRecord::Tasks::DatabaseTasks.db_dir = root.join("db")
    ActiveRecord::Tasks::DatabaseTasks.migrations_paths = [root.join("db/migrate")]
    # We don't have a seed loader but we don't want to default back to Rails.application
    # so define a stub seed loader.
    ActiveRecord::Tasks::DatabaseTasks.seed_loader = Class.new { def self.load_seed; end }
    ActiveRecord::Tasks::DatabaseTasks.root = root
    ActiveRecord::Base.configurations = ActiveRecord::Tasks::DatabaseTasks.database_configuration
  end
  Rake::Task["db:load_config"].enhance(["db:prepare_active_record"])
end

# Spec related rake tasks
RSpec::Core::RakeTask.new(:spec)

namespace :spec do
  task :initialize do
    ENV["RAILS_ENV"] ||= "test"
  end

  desc "Setup the database for running tests"
  task :setup => [:initialize, "db:test:prepare"]
end

task default: :spec

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

desc "Run rspec test"
task :test do
  Rake::Task["test:rspec"].invoke
end

namespace :test do
  RSpec::Core::RakeTask.new(:rspec) do |t|
    t.rspec_opts = "--format d -c"
  end
end

task :default => ['test']

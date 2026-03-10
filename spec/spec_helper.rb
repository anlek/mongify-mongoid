require 'rubygems'
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'mongify/mongoid'
require 'mongify/mongoid/cli'

begin
  require 'bundler'
  Bundler.setup
rescue LoadError
  puts "Need to install bundler 1.0. 'gem install bundler'"
end

require 'rspec/core'
require 'rspec/its'
require 'rspec/collection_matchers'
Dir['./spec/support/**/*.rb'].map {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.syntax = [:should, :expect]
  end
  config.expect_with :rspec do |expectations|
    expectations.syntax = [:should, :expect]
  end
end

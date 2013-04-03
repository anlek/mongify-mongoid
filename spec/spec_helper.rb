require 'rubygems'
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'mongify/mongoid'

begin
  require 'bundler'
  Bundler.setup
rescue LoadError
  puts "Need to install bundler 1.0. 'gem install bundler'"
end

require 'rspec/core'
#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
Bundler.require :default, :test

require 'rake'
APP_RAKEFILE = File.expand_path("../spec/test_app/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'
require "rspec/core/rake_task"

Bundler::GemHelper.install_tasks

task :default => :spec

# RSpec::Core::RakeTask.new(:spec) do |spec|
#   spec.pattern = 'spec/**/*_spec.rb'
#   # spec.rspec_opts = ['-cfs --backtrace']
# end


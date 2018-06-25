ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

require 'sidekiq-ent'

# require project files
Dir['./lib/**/*.rb'].each { |file| require file }


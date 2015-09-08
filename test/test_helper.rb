ENV["RACK_ENV"] ||= "test"

require 'bundler'
Bundler.require

require File.expand_path("../../config/environment", __FILE__)
require 'minitest/autorun'
require 'minitest/pride'
require 'capybara'
require 'database_cleaner'
require 'pry'
require 'json'
require 'tilt/erb'
require 'user_agent'
require 'mrspec'

DatabaseCleaner.strategy = :truncation, {except: %w[public.schema_migration]}

Capybara.app = TrafficSpy::Server
Capybara.save_and_open_page_path = "/tmp"

class FeatureTest < Minitest::Test
  include Capybara::DSL
end

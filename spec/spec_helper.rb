# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'sidekiq/testing/inline'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
  config.include MailerMacros
  config.include EmailSpec::Matchers

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.color_enabled = true

  # Clean up the database
  require 'database_cleaner'
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.orm = "mongoid"
  end

  config.before(:each) do
    DatabaseCleaner.clean
    reset_email
  end

  config.after(:each) do
    PusherFake::Channel.reset
  end
end

RspecApiDocumentation.configure do |config|
  config.docs_dir = Rails.root.join("docs", "public")
  config.api_name = "Subout API"
  config.url_prefix = "/api/doc"
  config.format = [:html]
end

# Use the same API key and secret as the live version.
PusherFake.configure do |configuration|
  configuration.app_id = Pusher.app_id
  configuration.key    = Pusher.key
  configuration.secret = Pusher.secret
end

# Set the host and port to the fake web server.
Pusher.host = PusherFake.configuration.web_host
Pusher.port = PusherFake.configuration.web_port

# Start the fake web server.
fork { PusherFake::Server.start }.tap do |id|
  at_exit { Process.kill("KILL", id) }
end

def sign_in_user(user = FactoryGirl.create(:user))
  sign_in user
  @current_company = user.company
  @current_user = user
end

def parse_json(json)
  JSON.parse(json)
end

def http_login
  user = ENV['SUBOUT_ADMIN_USERNAME']
  password = ENV['SUBOUT_ADMIN_PASSWORD']
  request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user, password)
end  

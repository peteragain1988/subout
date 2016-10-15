require 'cucumber/rails'
require 'email_spec/cucumber'
require 'sidekiq/testing/inline'
require 'database_cleaner/cucumber'

Capybara.default_selector = :css
Capybara.default_wait_time = 5

ActionController::Base.allow_rescue = false

DatabaseCleaner.strategy = :truncation

Before do
  DatabaseCleaner.clean
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
  Timecop.return
end

Cucumber::Rails::Database.javascript_strategy = :truncation

#require 'headless'
#headless = Headless.new
#headless.start


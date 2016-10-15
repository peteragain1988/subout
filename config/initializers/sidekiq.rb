if Rails.env.production?
  require 'sidekiq/web'

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && 
    password == ENV["SIDEKIQ_PASSWORD"]
  end
end

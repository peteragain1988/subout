ENV['YAHOO_GEO_KEY'] ||= "dj0yJmk9MkpzeGFVRjE0enBVJmQ9WVdrOVVXRTJZWEUzTm1zbWNHbzlNVEkzT0RjeU9UWXkmcz1jb25zdW1lcnNlY3JldCZ4PTY4"
ENV['YAHOO_GEO_SECRET'] ||= "7ad240ecd93551fc2c29355505a28f8b3298753a"

Geocoder.configure do |config|
  config.lookup = :yahoo
  config.api_key = [ENV['YAHOO_GEO_KEY'], ENV['YAHOO_GEO_SECRET']]
  config.timeout = 5
  config.units = :km
end

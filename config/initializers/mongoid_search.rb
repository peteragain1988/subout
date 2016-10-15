Mongoid::Search.setup do |config|
  ## Default matching type. Match :any or :all searched keywords
  config.match = :all

  ## If true, an empty search will return all objects
  config.allow_empty_search = true
end

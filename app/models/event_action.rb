class EventAction
  include Mongoid::Document

  TYPES = [
    :opportunity_created, 
    :opportunity_updated,
    :opportunity_canceled,
    :opportunity_awarded,
    :bid_created, 
    :opportunity_bidding_won, 
  ]

  field :type, type: Symbol 
  field :details, type: Hash, default: {}

  embedded_in :event
end

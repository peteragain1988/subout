class BidObserver < Mongoid::Observer
  observe :bid
  
  def after_create(bid)
    return if !bid.quote.blank?

    Event.create do |e|
      e.action = {type: :bid_created, details: {:amount => bid.amount, :bid_id => bid.id}}
      e.eventable = bid.opportunity
      e.actor_id = bid.bidder_id
    end

    bid.opportunity.update_value!

    Notifier.delay_for(5.minutes).new_bid(bid.id) if bid.opportunity.buyer.notification_items.include?("bid-new")
  end

  def after_update(bid)
    return if bid.changes.blank?
    if bid.canceled_changed?
      Event.create do |e|
        e.action = {type: :bid_canceled, details: {:amount => bid.amount, :bid_id => bid.id}}
        e.eventable = bid.opportunity
        e.actor_id = bid.bidder_id
      end
    elsif bid.offer_amount_changed? or bid.counter_amount_changed? or bid.state == 'declined'
      Event.create do |e|
        e.action = {type: :bid_negotiation, details: {:amount => bid.amount, :bid_id => bid.id}}
        e.eventable = bid.opportunity
        e.actor_id = bid.bidder_id
      end
    end
  end
end

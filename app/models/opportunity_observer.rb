require "xmlrpc/client"

class OpportunityObserver < Mongoid::Observer
  observe :opportunity

  def after_create(opportunity)
    #need to skip if its quote request one
    return if opportunity.for_quote_only

    create_event(opportunity, :opportunity_created)
    opportunity.notify_companies(:new_opportunity)
    opportunity.set(:was_ever_favorite_only, true) if opportunity.for_favorites_only?
  end

  def after_update(opportunity)
    return if opportunity.expired_notification_sent_changed?
    return if opportunity.changes.blank?

    if opportunity.canceled_changed?
      create_event(opportunity, :opportunity_canceled)
    elsif opportunity.awarded_changed?
      create_event(opportunity, :opportunity_awarded)
    elsif opportunity.winning_bid_id_changed?
      Event.create(actor_id: opportunity.winning_bid.bidder_id, action: {type: :opportunity_bidding_won}, eventable: opportunity)
    elsif opportunity.start_region_changed? or opportunity.end_region_changed? or opportunity.for_favorites_only_changed?
      create_event(opportunity, :opportunity_updated)
      opportunity.notify_companies(:new_opportunity)
    end
  end

  private

  def create_event(opportunity, type)
    Event.create!(actor_id: opportunity.buyer_id, action: {type: type}, eventable: opportunity)
  end
end



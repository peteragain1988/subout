class MailPreview < MailView
  def send_known_favorite_invitation
    buyer, supplier = Company.all[0, 2]
    Notifier.send_known_favorite_invitation(buyer.id, supplier.id)
  end

  def send_unknown_favorite_invitation
    invitation = FavoriteInvitation.first
    Notifier.send_unknown_favorite_invitation(invitation.id)
  end

  def new_bid
    bid = Bid.last
    Notifier.new_bid(bid.id)
  end

  def new_quote
    quote = Quote.last
    Notifier.new_quote(quote.id)
  end

  def expired_quote_request
    quote_request = QuoteRequest.last
    Notifier.expired_quote_request(quote_request.id)
  end

  def new_negotiation 
    bid = Bid.last
    Notifier.new_negotiation(bid.id)
  end

  def won_auction_to_buyer
    opportunity = Opportunity.where(:winning_bid_id.ne => nil).last
    Notifier.won_auction_to_buyer(opportunity.id)
  end

  def won_auction_to_supplier
    opportunity = Opportunity.where(:winning_bid_id.ne => nil).last
    Notifier.won_auction_to_supplier(opportunity.id)
  end

  def won_quote_to_consumer
    quote_request = QuoteRequest.where(:winning_quote_id.ne => nil).last
    Notifier.won_quote_to_consumer(quote_request.id)
  end

  def won_quote_to_quoter
    quote_request = QuoteRequest.where(:winning_quote_id.ne => nil).last
    Notifier.won_quote_to_quoter(quote_request.id)
  end

  def finished_auction_to_bidder
    opportunity = Opportunity.where(:winning_bid_id.ne => nil).last
    Notifier.finished_auction_to_bidder(opportunity.id, opportunity.bids.first.bidder_id)
  end

  def expired_auction_notification
    opportunity = Opportunity.where(:winning_bid_id.ne => nil).last
    Notifier.expired_auction_notification(opportunity.id)
  end

  def completed_auction_notification_to_buyer 
    opportunity = Opportunity.where(:winning_bid_id.ne => nil).last
    Notifier.completed_auction_notification_to_buyer(opportunity.id)
  end

  def completed_auction_notification_to_supplier 
    opportunity = Opportunity.where(:winning_bid_id.ne => nil).last
    Notifier.completed_auction_notification_to_supplier(opportunity.id)
  end

  def subscription_confirmation
    subscription = GatewaySubscription.last
    Notifier.subscription_confirmation(subscription.id)
  end

  def new_opportunity
    opportunity = Opportunity.last
    company = Company.last
    Notifier.new_opportunity(opportunity.id, company.id)
  end

  def new_quote_request
    quote_request = QuoteRequest.last
    company = Company.last
    Notifier.new_quote_request(quote_request.id, company.id)
  end

  def expired_card
    company = Company.last
    Notifier.expired_card(company.id)
  end

  def locked_company
    company = Company.last
    Notifier.locked_company(company.id)
  end

  def updated_product
    company = Company.last
    Notifier.updated_product(company.id)
  end

  def new_vehicle
    vehicle = Vehicle.first
    Notifier.new_vehicle(vehicle.id)
  end

  def update_vehicle
    vehicle = Vehicle.first
    Notifier.update_vehicle(vehicle.id, vehicle)
  end

  def remove_vehicle
    vehicle = Vehicle.first
    Notifier.remove_vehicle(vehicle)
  end

  def remind_registration_to_user
    subscription = GatewaySubscription.last
    Notifier.remind_registration_to_user(subscription.id)
  end

  def remind_registration_to_admin
    subscription = GatewaySubscription.last
    Notifier.remind_registration_to_admin(subscription.id)
  end

  def daily_reminder
    company = Company.last
    Notifier.daily_reminder(company.id)
  end

  def offered_auction_to_vendor
    offer = Offer.last
    Notifier.offered_auction_to_vendor(offer.id)
  end

  def accepted_offer_to_buyer
    offer = Offer.last
    Notifier.offered_auction_to_vendor(offer.id)
  end

  def accepted_offer_confirmation_to_vendor
    offer = Offer.last
    Notifier.accepted_offer_confirmation_to_vendor(offer.id)
  end

  def declined_offer_to_buyer
    offer = Offer.last
    new_opportunity = offer.opportunity
    Notifier.declined_offer_to_buyer(offer.id, new_opportunity.id)
  end

  def expired_offer_to_buyer
    offer = Offer.last
    new_opportunity = offer.opportunity
    Notifier.expired_offer_to_buyer(offer.id, new_opportunity.id)
  end

  def expired_offer_to_vendor
    offer = Offer.last
    Notifier.expired_offer_to_buyer(offer.id)
  end
end

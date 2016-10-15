class QuoteObserver < Mongoid::Observer
  observe :quote
  
  def after_create(quote)
    Bid.create_from_quote(quote)

    Event.create do |e|
      e.action = {type: :bid_created, details: {:amount => quote.amount, :quote_id => quote.id}}
      e.eventable = quote.quote_request
      e.actor_id = quote.quoter_id
    end

    Notifier.delay_for(5.minutes).new_quote(quote.id)
  end
end

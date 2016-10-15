class EventSerializer < ActiveModel::Serializer
  attributes :_id, :created_at, :regions, :eventable_company_id, :actor, :eventable_type, :eventable

  #for the speeding
  #has_one :actor, serializer: ActorShortSerializer
  has_one :action
  #has_one :eventable, polymorphic: true

  def eventable
    return QuoteRequestShortSerializer.new(object.eventable) if object.eventable_type=="QuoteRequest"
    return OpportunityShortSerializer.new(object.eventable)
  end

  def actor
    {:_id => object.actor_id}
  end
end

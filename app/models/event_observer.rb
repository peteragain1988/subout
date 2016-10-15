class EventObserver < Mongoid::Observer
  observe :event

  def after_create(event)
    unless DEVELOPMENT_MODE
      Pusher['global'].trigger!('event_created', EventSerializer.new(event).to_json)
    end
  end
end

class Api::V1::EventsController < Api::V1::BaseController
  def index
    events = Event.recent.for(current_company)
    events = events.where(:"action.type" => params[:event_type]) if params[:event_type]

    regions = params[:regions].split(',') unless params[:regions].blank?
    events = events.where(:regions.in => regions) unless regions.blank?

    events = events.where(:cached_eventable_type => params[:opportunity_type]) if params[:opportunity_type]
    events = events.where(:actor_id => params[:company_id]) if params[:company_id]
    events = events.search(params[:q]) if params[:q]
    events = events.page(params[:page])

    render json: events, array_serializer: EventShortSerializer, root: 'events', meta: { available_quote_request_count: QuoteRequest.not_expired.count }
  end

  def show
    event = Event.find(params[:id])
    render json: event
  end
end
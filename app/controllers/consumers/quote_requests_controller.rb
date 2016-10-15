class Consumers::QuoteRequestsController < Consumers::BaseController
  skip_before_filter :verify_authenticity_token, only: [:create]

  before_filter :check_retailer
  before_filter :check_retailer_host, only: [:new]
  before_filter :check_consumer_quote_request, only: [:select_winner, :show]
  after_action :allow_iframe, only: [:new, :create]

  def new
    @quote_request = QuoteRequest.new
    render :new, layout: 'consumer_embedded_html'
  end

  def create
    @quote_request = @retailer.quote_requests.new(quote_request_params)
    # @quote_request.retailer_host = @retailer_host

    if request.xhr?
      if @quote_request.save
        render :thankyou, layout: false
      else
        render :json=>{ errors: @quote_request.errors, error_messages: @quote_request.errors.full_messages }, status: 422
      end
    else
      if verify_recaptcha(:model => @quote_request, :message => "Oh! It's error with reCAPTCHA!") && @quote_request.save
        render :thankyou, layout: 'consumer_embedded_html'
      else
        @quote_request.valid?
        render :new, layout: 'consumer_embedded_html'
      end
    end
  end

  def show
  end

  def select_winner
    if !@quote_request.awarded?
      @quote_request.win!(@quote.id)
      render :winner
    else
      render :awarded
    end
  end

  private
  def quote_request_params
    params.require(:quote_request).permit(:organization, :first_name, :last_name, :email, :email_confirmation, :phone, :vehicle_type, :vehicle_count, :passengers,
      :start_location_address, :start_location_city, :start_location_state, :start_location_zip, :start_date, :start_time, :end_location_address, :end_location_city,
      :end_location_state, :end_location_zip, :departure_date, :departure_time, :trip_type, :description, :agreement)
  end

  def check_retailer
    @retailer = Retailer.where(id: params[:retailer_id]).first
    head :unauthorized if @retailer.blank?
  end

  def check_retailer_host
    return if @retailer.blank?
    return if request.referer.blank?
    @referer = URI.parse(request.referrer)
    @retailer_host = URI.parse(request.referrer).host
    head :unauthorized if !@retailer.valid_domain?(@retailer_host)
  end

  def check_consumer_quote_request
    @quote_request = QuoteRequest.where(reference_number: params[:id], email: params[:consumer_email], retailer_id: params[:retailer_id]).first
    @quote = @quote_request.quotes.where(reference_number: params[:quote_reference_number]).first if !@quote_request.blank?
    head :unauthorized if @quote.blank?
  end

  def set_layout
    layout 'consumer'
  end

end

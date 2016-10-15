class Api::V1::QuotesController < Api::V1::BaseController
  before_filter :set_quote_request
  def create
    quote = @quote_request.quotes.build(quote_params)
    quote.quoter = current_company
    quote.save

    respond_with_namespace(quote.quote_request, quote)
  end

  private

  def set_quote_request
    @quote_request ||= QuoteRequest.find(params[:quote_request_id])
  end

  def quote_params
    params.require(:quote).permit(:amount, :vehicle_count, :comment, :vehicles=>[:year, :type, :passenger_count, :gratuity_included])
  end
end

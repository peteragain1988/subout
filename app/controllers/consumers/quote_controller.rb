class Consumers::QuotesController < Consumers::BaseController
  skip_before_filter :verify_authenticity_token, only: [:create]

  private
  def check_consumer_quote_request
    @quote_request = QuoteRequest.where(reference_number: params[:id], email: params[:consumer_email], retailer_id: params[:retailer_id]).first
    @quote = @quote_request.quotes.where(reference_number: params[:quote_reference_number]).first if !@quote_request.blank?
    head :unauthorized if @quote.blank?
  end

end

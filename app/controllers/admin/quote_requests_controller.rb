class Admin::QuoteRequestsController < Admin::BaseController
  def index
    @quote_requests = QuoteRequest.order_by(created_at: :desc).page(params[:page]).per(20)
  end
end
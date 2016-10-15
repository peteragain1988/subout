class Api::V1::QuoteRequestsController < Api::V1::BaseController
  def show
    if @quote_request = QuoteRequest.where('$or' => [{:id => params[:id]}, {:reference_number => params[:id]}]).first
      respond_with_namespace(@quote_request)
    else
      render json: { errors: { base: "Record not found" } }, status: 404
    end
  end
end

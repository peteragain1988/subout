class Api::V1::OpportunitiesController < Api::V1::BaseController
  def index
    params[:page] ||= 1
    opportunities = current_company.available_opportunities(params[:sort_by], params[:sort_direction], params[:start_date], params[:vehicle_types], params[:trip_type], params[:query], params[:regions])
    meta = {
      :count =>  opportunities.count,
      :per_page => Opportunity.default_per_page,
      :page => params[:page].to_i,
    }
    render json: opportunities.page(params[:page]), root: "opportunities", meta: meta
  end

  def show
    if @opportunity = Opportunity.where('$or' => [{:id => params[:id]}, {:reference_number => params[:id]}]).first
      @opportunity.viewer = current_company
      respond_with_namespace(@opportunity)
    else
      render json: { errors: { base: "Record not found" } }, status: 404
    end
  end
end

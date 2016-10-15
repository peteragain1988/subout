class Admin::RevenuesController < Admin::BaseController
  def index
    params[:start_date] = params[:start_date] || Date.today.beginning_of_month.to_s 
    params[:end_date] = params[:end_date] || Date.today.to_s
    params[:sort_by] = params[:sort_by] || 'posted_oppor_count'
    params[:sort_order] = params[:sort_order] || 'desc'

    @revenues = GatewaySubscription.revenues(params)
  end
end

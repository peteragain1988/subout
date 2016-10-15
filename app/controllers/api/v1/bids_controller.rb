class Api::V1::BidsController < Api::V1::BaseController

  def index
    params[:page] ||= 1
    bids = current_company.bids.recent
    meta = {
      :count =>  bids.count,
      :per_page => Bid.default_per_page,
      :page => params[:page].to_i,
    }
    render json: bids.includes(:opportunity).page(params[:page]), root: "bids", meta: meta
  end

  def create
    bid = opportunity.bids.build(bid_params)
    bid.bidder = current_company
    bid.save
    respond_with_namespace(bid.opportunity, bid)
  end

  def cancel
    bid = current_company.bids.find(params[:id])
    bid.cancel

    respond_with_namespace(bid.opportunity, bid)
  end

  def accept_negotiation
    bid = current_company.bids.find(params[:id])
    opportunity = bid.opportunity

    if opportunity.canceled?
      render json: { errors: { base: ["This opportunity is canceled."] } }, status: :unprocessable_entity
    elsif opportunity.awarded?
      render json: { errors: { base: ["This opportunity is already awarded by another bidder."] } }, status: :unprocessable_entity
    else
      opportunity.win!(params[:id])
      render json: opportunity, serializer: OpportunitySerializer
    end
  end

  def decline_negotiation 
    bid = current_company.bids.find(params[:id])
    bid.decline!
    render json: bid.opportunity, serializer: OpportunitySerializer
  end

  def counter_negotiation 
    bid = current_company.bids.find(params[:id])
    new_amount = params[:bid][:amount]    
    bid.counter_negotiation!(new_amount)
    unless bid.errors.blank?
      render json: { errors: bid.errors }, status: :unprocessable_entity
    else
      render json: bid.opportunity, serializer: OpportunitySerializer
    end
  end

  private

  def opportunity
    @opportunity ||= Opportunity.find(params[:opportunity_id])
  end

  def bid_params
    params.require(:bid).permit(:amount, :auto_bidding_limit, :comment, :vehicle_count, :vehicle_count_limit, :vehicles=>[:year, :type, :passenger_count, :gratuity_included])
  end
end

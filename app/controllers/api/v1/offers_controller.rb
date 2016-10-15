class Api::V1::OffersController < Api::V1::BaseController

  before_filter :set_vendor, only: [:create]

  def create
    if @vendor.blank?
      render_404
      return
    end

    offer = opportunity.build_offer(offer_params)
    offer.vendor = @vendor
    if offer.save
      opportunity.award!
    end
    respond_with_namespace(offer.opportunity, offer)
  end

  private

  def opportunity
    @opportunity ||= Opportunity.find(params[:opportunity_id])
  end
  
  def offer_params
    params.require(:offer).permit(:amount, :vehicle_type)
  end

  def vendor_params
    params.require(:vendor).permit(:id, :name, :email, :crm_vendor_id)
  end

  def set_vendor
    @vendor = Vendor.where(email: vendor_params[:email]).first
  end
end

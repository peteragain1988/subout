class Vendors::OffersController < Vendors::BaseController
  before_filter :set_offer
  before_filter :restrict_access

  def accept
    if @offer.is_active?
      @offer.accept!
      flash.now[:success] = "Accepted!"
    else
      flash.now[:danger] = "Couldn't accept!"
    end
    render :show
  end

  def decline
    if @offer.is_active?
      @offer.decline!
      flash.now[:success] = "Declined!"
    else
      flash.now[:danger] = "Couldn't decline!"
    end
    render :show
  end

  def show
    flash.now[:danger] = "Sorry, this offer is expired." if !@offer.live?
  end

  private
  def set_offer
    @offer = Offer.where(reference_number: params[:id]).first
  end

  def restrict_access
    head :unauthorized if @offer.blank? or @offer.token!=params[:token]
  end
end

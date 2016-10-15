class Retailers::ProfilesController < Retailers::BaseController
  def edit
    @retailer = current_retailer
  end

  def update
    current_retailer.update_attributes(retailer_params) 
    redirect_to edit_retailers_profile_path
  end

  private
  def retailer_params
    params.require(:retailer).permit(:domains)
  end
end

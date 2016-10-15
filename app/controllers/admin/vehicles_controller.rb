class Admin::VehiclesController < Admin::BaseController
  before_filter :load_vehicle, :load_company

  def edit

  end

  def update
    if @vehicle.update_attributes(params[:vehicle])
      redirect_to edit_admin_company_path(@company), notice: "Vehicle is updated."
    else
      render :edit
    end
  end

  private

  def load_vehicle
    @vehicle = Vehicle.find(params[:id])
  end

  def load_company
    @company = Company.find(params[:company_id])
  end
end
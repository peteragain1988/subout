class Api::V1::VendorsController < Api::V1::BaseController
  def index
    vendor = Vendor.where(email: params[:email]).first
    respond_with_namespace vendor
  end

  def show
    vendor = Vendor.where(id: params[:id]).first
    respond_with_namespace vendor
  end
end
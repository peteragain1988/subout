class Api::V1::FiltersController < Api::V1::BaseController
  def index
    render :file => "#{Rails.root}/db/api/_filters", :formats => [:json]
  end
end

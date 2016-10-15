class Api::V1::TagsController < Api::V1::BaseController
  def index
    render :file => "#{Rails.root}/db/api/_tags", :formats => [:json]
  end
end

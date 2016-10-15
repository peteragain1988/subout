class Api::V1::RatingsController < Api::V1::BaseController
  def update
    @rating = Rating.find(params[:id])
    if @rating.editable
      @rating.update_attributes(rating_params)
      @rating.lock!
      respond_with_namespace(@rating)
    else
      render json: { errors: { editable: "Rating is locked." } }, status: 404
    end
  end

  def rating_params
    params.require(:rating).permit(:communication, :punctuality, :ease_of_payment, :over_all_experience, :like_again, :trip_expected) 
  end
end

class Api::V1::UsersController < Api::V1::BaseController
  def update
    if current_user.update_with_password(params.require(:user).permit(:current_password, :password, :password_confirmation))
      render json: current_user
    else
      render json: {}, status: 422
    end
  end

  def show
    user = User.find(params[:id])
    respond_with_namespace(user)
  end
end

class Api::V1::TokensController < Api::V1::BaseController
  skip_before_filter :restrict_access
  skip_before_filter :restrict_ghost_user

  def create
    username = params[:email].downcase.strip if params[:email]
    if user = User.where(:email => /^#{username}$/i).first
      subscription = user.company.created_from_subscription
      if user.access_locked?
        render :json => { authorized: false, message: "Your account is locked. Please contact admin."}
      elsif (!user.company.has_subscription_benefit? and user.company.created_from_subscription.blank?) 
        render :json => { authorized: false, message: "You don't have valid subscription plan. Please contact admin."}
      elsif (!user.company.has_subscription_benefit? and user.company.has_canceled_subscription?) 
        render :json => { authorized: false, message: "You have canceled subscription. Please contact admin."}
      elsif user.valid_password?(params[:password])
        if params[:deviceToken]
          key = params[:deviceToken]
          device_type = params[:deviceType]

          user.mobile_keys.find_or_create_by(key: key, device_type: device_type)
        end

        render json: user.auth_token_hash
        user.update_tracked_fields!(request)
      else
        render :json => { authorized: false, message: "Invalid password!"}
      end
    else
      render :json => { authorized: false, message: "Invalid username or password!"}
    end
  end
end

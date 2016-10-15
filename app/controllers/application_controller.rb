class ApplicationController < ActionController::Base
  before_filter :check_uri
  before_filter :https_redirect
  before_filter :prepare_mobile
  layout :layout_by_resource

  private

  def after_sign_in_path_for(resource_or_scope)
    edit_retailers_profile_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_retailer_session_path
  end

  def layout_by_resource
    if devise_controller? && resource_name == :retailer
      "devise"
    else
      "application"
    end
  end

  def check_uri
    redirect_to "https://www.suboutapp.com#{request.fullpath}" if "suboutapp.com" == request.host
  end

  def https_redirect
    if ENV["ENABLE_HTTPS"]
      if !request.ssl?
        flash.keep
        redirect_to protocol: "https://", status: :moved_permanently
      end
    end
  end

  def prepare_mobile
    session[:mobile] = params[:mobile] if !params[:mobile].nil?
  end

  def mobile_device?
    if session[:mobile]
      session[:mobile] == "1"
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end
  
  def allow_iframe
    response.headers.delete('X-Frame-Options')
  end

  helper_method :mobile_device?
end

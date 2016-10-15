class Api::V1::BaseController < ActionController::Base
  respond_to :json

  before_filter :restrict_access
  before_filter :restrict_ghost_user

  unless Rails.application.config.consider_all_requests_local
    rescue_from Mongoid::Errors::DocumentNotFound, :with => :render_404
  end

  private

  def restrict_access
    return if params[:api_token] and current_user
    head :unauthorized
  end

  def restrict_ghost_user
    if current_user and current_user.company.mode == 'ghost'
      if ['PUT', 'POST', 'DELETE'].include?(request.method)
        render :json => {'errors' => {'base' => ["Permission denied. #{Setting.get('promotion_message')}"]}}, :status => 403
      end
    end
  end

  def current_user
    @current_user ||= User.find_by(authentication_token: params[:api_token])
    if @current_user.access_locked?
      raise Mongoid::Errors::DocumentNotFound.new(User, @current_user.id, @current_user.id)
    end
    @current_user
  end

  def current_company
    current_user.company
  end

  def render_404
    render :json => {:error => "not-found"}.to_json, :status => 404
  end

  def respond_with_namespace(*resource)
    respond_with(:api, :v1, *resource)
  end
end

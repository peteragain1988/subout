class Admin::BaseController < ApplicationController
  before_filter :authenticate
  layout 'admin'

  def index

  end

  protected

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      return false if ENV['SUBOUT_ADMIN_PASSWORD'].blank?
      username == ENV['SUBOUT_ADMIN_USERNAME'] && password == ENV['SUBOUT_ADMIN_PASSWORD']
    end
  end
end

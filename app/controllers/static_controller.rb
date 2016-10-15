class StaticController < ApplicationController

  def index
    setup_headers

    index_name = 'production'
    index_name = 'development' if Rails.env.development? || Rails.env.test?
    
    if !mobile_device?
      file_name = "public/index_#{index_name}.html"
      render :inline => File.read(file_name), :layout => nil
    else
      file_name = "public/mo/index_#{index_name}.html"
      render :inline => File.read(file_name), :layout => nil
    end
  end

  def embedded
    setup_headers

    index_name = 'production'
    index_name = 'development' if Rails.env.development? || Rails.env.test?
    
    file_name = "public/embedded_#{index_name}.html"
    render :inline => File.read(file_name), :layout => nil
  end

  def asset
    setup_headers

    timestamp = params[:timestamp]
    path      = params[:path]
    timestamp = Time.now.to_i if timestamp == '--DEPLOY--'
    
    qs = path.include?("?") ? "&" : "?"
    redirect_to "/#{path}#{qs}t=#{timestamp}"
    
  end

  def setup_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"]        = "no-cache"
    response.headers["Expires"]       = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

end

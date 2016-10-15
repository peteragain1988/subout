class ApiVersion
  def initialize(app)
    @app = app
  end
  
  def call(env)
    status, headers, response = @app.call(env)
    if headers["Content-Type"] =~ /application\/json/
      data = response.body.to_s
      data = '{}' if data.empty?
      response.body = "{ \"payload\":#{data}, \"version\":#{SUBOUT_APP_VERSION}, \"deploy\":#{SUBOUT_DEPLOY_VERSION}}"
    end
    [status, headers, response]
  end
end

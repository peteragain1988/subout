require 'sinatra'

class ApiDoc < Sinatra::Base
  set :public_folder, File.dirname(__FILE__) + '/public'

  get '/' do
    File.read(File.join(File.dirname(__FILE__), "public", "index.html"))
  end
end

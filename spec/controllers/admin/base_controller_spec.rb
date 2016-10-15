require 'spec_helper'

describe Admin::BaseController, "GET 'index'" do
  it "renders a template" do
    http_login

    get :index

    response.status.should == 200
    response.should render_template("index")
  end
end

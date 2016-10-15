require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Authentication" do
  let!(:user) { FactoryGirl.create(:user, email: email, password: password, password_confirmation: password) }

  post "/api/v1/tokens.json" do
    parameter :email, "Email Address"
    parameter :password, "Password"
    required_parameters :email, :password

    let(:email) { "user@email.com" }
    let(:password) { "password" }

    example_request "Sign In" do
      status.should == 200
    end
  end
end

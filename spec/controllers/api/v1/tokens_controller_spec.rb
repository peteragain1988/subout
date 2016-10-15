require 'spec_helper'

describe Api::V1::TokensController do
  let(:user) { FactoryGirl.create(:user, password: "password1") }

  describe "POST 'create'" do
    context "with valid email and password" do
      it "responds token" do
        post :create, email: user.email, password: "password1"

        token = parse_json(response.body)
        token["authorized"].should be_true
        token["api_token"].should == user.authentication_token
      end
    end

    context "with invalid email or password" do
      it "responds with authorized false" do
        post :create, email: user.email, password: "invalid"

        token = parse_json(response.body)
        token["authorized"].should be_false
      end
    end
  end
end

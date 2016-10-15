require 'spec_helper'

describe Api::V1::PasswordsController, "POST create" do
  let(:user) { FactoryGirl.create(:user, email: "test@email.com") }

  it "sends reset password instruction" do
    post :create, user: { email: user.email }

    response.status.should == 200
    user.reload.reset_password_token.should_not be_nil
  end
end

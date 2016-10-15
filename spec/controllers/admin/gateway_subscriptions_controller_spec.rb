require 'spec_helper'

describe Admin::GatewaySubscriptionsController, "GET index" do
  it "renders a template" do
    http_login

    get :index

    response.status.should == 200
    response.should render_template("index")
  end
end

describe Admin::GatewaySubscriptionsController, "PUT resend_invitation" do
  let!(:subscription) { FactoryGirl.create(:gateway_subscription) }

  it "sends invitation again" do
    http_login

    Notifier.should_receive(:subscription_confirmation).with(subscription.id)

    put :resend_invitation, id: subscription.id
    response.should redirect_to(admin_gateway_subscriptions_path)
  end
end

describe Admin::GatewaySubscriptionsController, "GET edit" do
  let!(:subscription) { FactoryGirl.create(:gateway_subscription) }

  it "render a template" do
    http_login

    get :edit, id: subscription.id

    response.should render_template("edit")
  end
end

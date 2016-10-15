require 'spec_helper'

describe Api::V1::GatewaySubscriptionsController, "GET connect_company" do
  it "redirects to sign up page" do
    subscription = FactoryGirl.create(:gateway_subscription)

    get :connect_company, chargify_id: subscription.subscription_id

    response.should redirect_to("/#/sign_up?subscription_id=#{subscription.id}")
  end

  context "with company_id" do
    it "connects company and redirects to dashboard" do
      subscription = FactoryGirl.create(:gateway_subscription)
      company = FactoryGirl.create(:company, created_from_subscription: nil)

      get :connect_company, chargify_id: subscription.subscription_id, company_id: company.id

      response.should redirect_to("/#/dashboard")
      company.reload.created_from_subscription_id.should == subscription.id
    end
  end

  context "when the given company is already connected with other subscription" do
    it "redirects to sign in page" do
      subscription = FactoryGirl.create(:gateway_subscription)
      subscription2 = FactoryGirl.create(:gateway_subscription)
      company = FactoryGirl.create(:company, created_from_subscription: subscription)

      get :connect_company, chargify_id: subscription2.subscription_id, company_id: company.id

      response.should redirect_to("/#/sign_in")

      company.reload.created_from_subscription_id.should == subscription.id
    end
  end

  context "when the subscription is already connected with other company" do
    it "redirects to sign in page" do
      subscription = FactoryGirl.create(:gateway_subscription)
      company = FactoryGirl.create(:company, created_from_subscription: subscription)

      get :connect_company, chargify_id: subscription.subscription_id

      response.should redirect_to("/#/sign_in")
    end
  end
end

describe Api::V1::GatewaySubscriptionsController, "POST create" do
  it "creates a gateway subscription" do
    payload = {
      subscription: {
        id: "subscription_id",
        customer: {
          id: "customer_id",
          email: "customer@email.com",
          first_name: "Bill",
          last_name: "James",
          organization: "Company"
        },
        product: {
          handle: "state-by-state-service"
        }
      }
    }

    post :create, payload: payload

    response.status.should == 200
    GatewaySubscription.should have(1).item
  end
end

describe Api::V1::GatewaySubscriptionsController, "GET show" do
  it "returns json for gateway subscription" do
    subscription = FactoryGirl.create(:gateway_subscription)

    get :show, id: subscription.id

    response.status.should == 200
    parse_json(response.body).should be
  end
end

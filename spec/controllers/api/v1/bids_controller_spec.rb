require 'spec_helper'

describe Api::V1::BidsController do
  let(:user) { FactoryGirl.create(:user) }

  describe "GET 'index'" do
    it "responds all bids of user's company" do
      FactoryGirl.create_list(:bid, 2, bidder: user.company)
      FactoryGirl.create(:bid)

      get :index, api_token: user.authentication_token, format: 'json'

      bids = parse_json(response.body)
      bids.should have(2).items
    end

    context "with opportunity_id" do
      let(:opportunity) { FactoryGirl.create(:opportunity) }

      it "responds my bids" do
        FactoryGirl.create_list(:bid, 2, bidder: user.company)
        FactoryGirl.create(:bid)

        get :index, opportunity_id: opportunity.id, api_token: user.authentication_token, format: 'json'

        bids = parse_json(response.body)
        bids.should have(2).items
      end
    end
  end

  describe "POST 'create'" do
    let(:opportunity) { FactoryGirl.create(:opportunity) }

    it "responds bid" do
      bid_attributes = FactoryGirl.attributes_for(:bid)

      expect {
        post :create, bid: bid_attributes, opportunity_id: opportunity.id, api_token: user.authentication_token, format: 'json'
      }.to change(opportunity.bids, :count).by(1)

      response.status.should == 201
    end

    context "bid again on the oppportunity" do
      it "responds error if amount is higher than my previous bids" do
        FactoryGirl.create(:bid, opportunity: opportunity, bidder: user.company, amount: 100.0)

        bid_attributes = FactoryGirl.attributes_for(:bid, amount: 101.0)

        post :create, bid: bid_attributes, opportunity_id: opportunity.id, api_token: user.authentication_token, format: 'json'

        response.status.should == 422
      end
    end
  end
end

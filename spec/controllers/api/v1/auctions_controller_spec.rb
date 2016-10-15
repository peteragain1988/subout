require 'spec_helper'

describe Api::V1::AuctionsController do
  let(:user) { FactoryGirl.create(:user) }

  describe "GET 'index'" do
    it "responds all auctions of a company" do
      FactoryGirl.create_list(:auction, 2, buyer: user.company)
      FactoryGirl.create(:auction) 

      get :index, api_token: user.authentication_token, format: 'json'

      auctions = parse_json(response.body)
      auctions.should have(2).items
    end
  end

  describe "POST 'create'" do
    context "with valid parameters" do
      it "responds 201" do
        auction_attribtes = FactoryGirl.attributes_for(:auction)

        post :create, opportunity: auction_attribtes, api_token: user.authentication_token, format: 'json'

        response.code.should eq("201")
      end
    end

    context "with invalid parameters" do
      it "responds 422" do
        auction_attribtes = FactoryGirl.attributes_for(:auction, name: nil)

        post :create, opportunity: auction_attribtes, api_token: user.authentication_token, format: 'json'

        response.code.should eq("422")
      end
    end
  end

  describe "GET 'show'" do
    it "responds an auction" do
      auction = FactoryGirl.create(:auction, buyer: user.company)

      get :show, id: auction.id, api_token: user.authentication_token, format: 'json'

      result = parse_json(response.body)
      result["name"].should == auction.name
    end
  end

  describe "PUT 'select_winner'" do
    let(:opportunity) { FactoryGirl.create(:auction, buyer: user.company) }

    it "responds success" do
      Opportunity.any_instance.should_receive(:win!).with('bid_id')

      put :select_winner, id: opportunity.id, bid_id: 'bid_id', api_token: user.authentication_token, format: 'json'

      response.should be_success
    end

    context "when the opportunity is canceled" do
      it "returns error" do
        opportunity.cancel!

        put :select_winner, id: opportunity.id, bid_id: 'bid_id', api_token: user.authentication_token, format: 'json'

        response.status.should == 422
        parse_json(response.body)["errors"].should be
      end
    end
  end

  describe "PUT 'update'" do
    it "responds success" do
      auction = FactoryGirl.create(:auction, buyer: user.company, name: "Old name")

      put :update, id: auction.id, opportunity: {name: "New name"}, api_token: user.authentication_token, format: 'json'

      response.should be_success
      auction.reload.name.should == "New name"
    end

    context "when there is a bid" do
      it "responds error" do
        auction = FactoryGirl.create(:auction, buyer: user.company, name: "Old name")
        FactoryGirl.create(:bid, opportunity: auction)

        put :update, id: auction.id, opportunity: {name: "New name"}, api_token: user.authentication_token, format: 'json'

        response.status.should == 422
        auction.reload.name.should == "Old name"
      end
    end
  end

  describe "PUT 'cancel'" do
    let(:opportunity) { FactoryGirl.create(:auction, buyer: user.company) }

    it "cancels the opportunity" do
      put :cancel, id: opportunity.id, api_token: user.authentication_token, format: 'json'

      response.status.should == 200
      opportunity.reload.should be_canceled
    end

    context "when there is a bid on the opportunity" do
      it "responds error" do
        FactoryGirl.create(:bid, opportunity: opportunity)

        put :cancel, id: opportunity.id, api_token: user.authentication_token, format: 'json'

        response.status.should == 422
        parse_json(response.body)["errors"].should be
      end
    end
  end
end

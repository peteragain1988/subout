require 'spec_helper'

describe Api::V1::EventsController do
  let(:user) { FactoryGirl.create(:user) }

  describe "GET 'index'" do
    let!(:opportunity1) { FactoryGirl.create(:opportunity) }
    let!(:opportunity2) { FactoryGirl.create(:opportunity) }

    it "responds events" do
      get :index, api_token: user.authentication_token, format: 'json'

      response.status.should == 200
      result = parse_json(response.body)
      result.should have(2).items
    end
  end
end

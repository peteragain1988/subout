require 'spec_helper'

describe Api::V1::CommentsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:opportunity) { FactoryGirl.create(:opportunity) }

  describe "POST 'create'" do
    it "responds bid" do
      post :create, comment: { body: "New Comment" }, opportunity_id: opportunity.id, api_token: user.authentication_token, format: 'json'

      response.status.should == 201
      opportunity.reload
      opportunity.comments.count.should == 1
    end
  end
end

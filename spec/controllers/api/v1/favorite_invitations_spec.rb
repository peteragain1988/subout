require 'spec_helper'

describe Api::V1::FavoriteInvitationsController do
  describe "GET 'show'" do
    it "responds invitation resource via invitation token" do
      invitation = FactoryGirl.create(:favorite_invitation)

      get :show, id: invitation.id, format: 'json'

      response.should be_success
      parse_json(response.body)["supplier_name"].should == invitation.supplier_name
    end
  end
end

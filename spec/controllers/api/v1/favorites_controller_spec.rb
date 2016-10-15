require 'spec_helper'

describe Api::V1::FavoritesController do
  let(:user) { FactoryGirl.create(:user) }

  describe "DELETE 'destroy'" do
    it "remove a company from my favorites" do
      company = FactoryGirl.create(:company)
      user.company.add_favorite_supplier!(company)
      user.company.add_favorite_supplier!(FactoryGirl.create(:company))

      delete :destroy, id: company.id, api_token: user.authentication_token, format: :json

      response.should be_success
      user.company.reload.favorite_suppliers.count.should == 1
    end
  end
end


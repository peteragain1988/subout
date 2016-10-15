require 'spec_helper'

describe Event do
  describe ".for" do
    let!(:ca_opportunity) {FactoryGirl.create(:opportunity, start_region: "California")}
    let!(:wa_opportunity) {FactoryGirl.create(:opportunity, start_region: "Washington")}
    let!(:favorite_only_opportunity) {FactoryGirl.create(:opportunity, start_region: "California", for_favorites_only: true)}
    let(:national_plan_company) {FactoryGirl.create(:company)}
    let(:ca_state_plan_company) {FactoryGirl.create(:ca_company)}

    context "a company with national plan is given" do
      it "returns all events except favorites only ones" do
        Event.for(national_plan_company).should have(2).items
      end
    end

    context "a company with state by state plan is given" do
      it "returns all events except favorites only ones" do
        Event.for(ca_state_plan_company).should have(2).items
      end
    end
  end
end

require 'spec_helper'

describe Company do
  it "should generate company message path by default" do
    c = FactoryGirl.create(:company)
    expect(c.company_msg_path).not_to be_empty
  end

  describe "#add_favorite_supplier!" do
    let!(:supplier) {FactoryGirl.create(:company)}
    let!(:buyer) {FactoryGirl.create(:company)}
    it 'adds the supplier to the favorite suppliers list' do
      buyer.add_favorite_supplier!(supplier)
      buyer.favorite_supplier_ids.should include(supplier.id)
    end

    it 'adds the buyer to the suppliers favoriting_buyers list' do
      buyer.add_favorite_supplier!(supplier)
      supplier.favoriting_buyer_ids.should include(buyer.id)
    end
  end

  describe "#favorite_suppliers" do
    it 'returns the list of favortie suppliers' do
      supplier = FactoryGirl.create(:company)
      buyer = FactoryGirl.create(:company)
      buyer.favorite_supplier_ids << supplier.id
      buyer.save

      buyer.favorite_suppliers.should include(supplier)
    end
  end

  describe ".available_opportunities" do
    let(:poster) { FactoryGirl.create(:company) }
    let!(:ca_subscriber) { FactoryGirl.create(:ca_company) }
    let!(:ma_subscriber) { FactoryGirl.create(:ma_company) }
    let!(:national_subscriber) { FactoryGirl.create(:company) }
    let!(:favorited_ca_subscriber) { FactoryGirl.create(:ca_company) }

    before do
      poster.add_favorite_supplier!(favorited_ca_subscriber)
    end

    context "favorite only opportunity" do
      let!(:fav_only_opportunity) { FactoryGirl.create(:opportunity, for_favorites_only: true, buyer: poster) }

      it { favorited_ca_subscriber.available_opportunities.should include(fav_only_opportunity) }
      it { ma_subscriber.available_opportunities.should_not include(fav_only_opportunity) }
      it { national_subscriber.available_opportunities.should_not include(fav_only_opportunity) }
    end

    context "non favorite only Massachusetts opportunity" do
      let!(:ma_opportunity) { FactoryGirl.create(:opportunity, buyer: poster) }

      it { national_subscriber.available_opportunities.should include(ma_opportunity) }
      it { ma_subscriber.available_opportunities.should include(ma_opportunity) }
      it { ca_subscriber.available_opportunities.should_not include(ma_opportunity) }
      it { favorited_ca_subscriber.available_opportunities.should_not include(ma_opportunity) }
    end

    context "canceled opportunity" do
      let!(:ma_opportunity) { FactoryGirl.create(:opportunity, buyer: poster) }
      before { ma_opportunity.update_attribute(:canceled, true) }

      it { national_subscriber.available_opportunities.should_not include(ma_opportunity) }
    end

    context "ended opportunity" do
      let!(:ma_opportunity) { FactoryGirl.create(:opportunity, buyer: poster) }
      before { ma_opportunity.update_attribute(:created_at, 2.days.ago) }

      it { national_subscriber.available_opportunities.should_not include(ma_opportunity) }
    end

    context "won opportunity" do
      let!(:ma_opportunity) { FactoryGirl.create(:opportunity, buyer: poster, winning_bid_id: "some_id") }

      it { national_subscriber.available_opportunities.should_not include(ma_opportunity) }
    end

    context "own opportunities" do
      let!(:ma_opportunity) { FactoryGirl.create(:opportunity, buyer: poster) }

      it { poster.available_opportunities.should_not include(ma_opportunity) }
    end

    context "when sort_by and sort_direction are nil" do
      it { lambda { poster.available_opportunities(nil, nil) }.should_not raise_error }
    end
  end
end

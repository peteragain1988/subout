require 'spec_helper'

describe Opportunity do
  describe "validation" do
    it { should allow_value(nil).for(:win_it_now_price) }
    it { should allow_value(1).for(:win_it_now_price) }
    it { should_not allow_value(0).for(:win_it_now_price) }
    it { should_not allow_value(-1).for(:win_it_now_price) }
    it { should_not allow_value(-1).for(:win_it_now_price) }
    it { should allow_value("1").for(:bidding_duration_hrs) }
    it { should_not allow_value("0").for(:bidding_duration_hrs) }
    it { should_not allow_value("-1").for(:bidding_duration_hrs) }
    it { should allow_value("Sedan").for(:vehicle_type) }
    it { should_not allow_value("Truck").for(:vehicle_type) }
    it { should allow_value("One way").for(:trip_type) }
    it { should_not allow_value("Three ways").for(:trip_type) }
  end

  describe "#win!" do
    include EmailSpec::Helpers

    let(:winner) { FactoryGirl.create(:company) }
    let(:loser) { FactoryGirl.create(:company) }
    let!(:auction) { FactoryGirl.create(:auction) }
    let!(:bid) { FactoryGirl.create(:bid, opportunity: auction, bidder: winner, amount: 100) }
    let!(:other_bid) { FactoryGirl.create(:bid, opportunity: auction, bidder: loser) }
    let!(:won_bid) { FactoryGirl.create(:bid, opportunity: auction, bidder: winner, amount: 90) }

    it "closes the auction"  do
      expect {
        auction.win!(won_bid.id)
      }.to change(auction, :bidding_done)
    end

    it "records the winning bid" do
      expect {
        auction.win!(won_bid.id)
      }.to change(auction, :winning_bid_id)

    end

    it "notifies to the buyer" do
      auction.win!(won_bid.id)

      find_email(auction.buyer.email, with_subject: /has won the bidding/).should_not be_nil
    end

    it "notifies the winner" do
      auction.win!(won_bid.id)

      find_email(winner.email, with_subject: /You won the bidding/).should_not be_nil
      find_email(winner.email, with_subject: /You didn't win the bidding/).should be_nil
    end

    it "notities to other bidders" do
      auction.win!(won_bid.id)

      find_email(loser.email, with_subject: /You won the bidding/).should be_nil
      find_email(loser.email, with_subject: /You didn't win the bidding/).should_not be_nil
    end
  end

  describe "#bidable?" do
    it "returns false if the opportunity has been canceled" do
      opportunity = Opportunity.new(canceled: true)

      opportunity.should_not be_bidable
    end

    it "returns false if the opportunity has been done" do
      opportunity = Opportunity.new(bidding_done: true)

      opportunity.should_not be_bidable
    end

    it "returns false if the opportunity has been won by a company" do
      opportunity = Opportunity.new(winning_bid_id: "123")

      opportunity.should_not be_bidable
    end

    it "returns false if the opportunity has been ended" do
      opportunity = Opportunity.new(created_at: 2.hours.ago, bidding_duration_hrs: "1") 
      opportunity.send(:set_bidding_ends_at)
      opportunity.should_not be_bidable
    end
  end

  describe ".send_expired_notification" do
    it "sends expired opportunity notification" do
      opportunity = FactoryGirl.create(:auction, created_at: 2.hour.ago, bidding_duration_hrs: "1")
      Opportunity.send_expired_notification

      opportunity.reload.expired_notification_sent.should == true
    end
  end

  describe "#editable?" do
    let(:opportunity) { FactoryGirl.create(:opportunity) }

    subject { opportunity }
    it { should be_editable }

    context "when there is a bid" do
      before { FactoryGirl.create(:bid, opportunity: opportunity) }
      it { should_not be_editable }
    end

    context "when the opportunity is canceled" do
      before { opportunity.cancel! }
      it { should_not be_editable }
    end
  end

  describe "validate_time" do
    it "validates start_time" do
      FactoryGirl.build(:opportunity, start_time: "25:00").should_not be_valid
    end

    it "validates end_time" do
      FactoryGirl.build(:opportunity, end_time: "25:00").should_not be_valid
    end
  end

  describe "#companies_to_notify" do
    let!(:locked_company) { FactoryGirl.create(:ma_company, locked_at: Time.now) }
    let!(:ca_company) { FactoryGirl.create(:ca_company) }
    let!(:ma_company) { FactoryGirl.create(:ma_company) }
    let!(:ca_ma_company) do
      company = FactoryGirl.create(:ma_company)
      company.set(:regions, ["Massachusetts", "California"])
      company
    end
    let!(:national_company) { FactoryGirl.create(:company) }
    let!(:buyer) { FactoryGirl.create(:ma_company) }
    let!(:fav_company) do
      company = FactoryGirl.create(:ma_company)
      buyer.add_favorite_supplier!(company)
      company.set(:regions, [])
      company
    end

    context "when first created" do
      it "notifies all companies based on current regions" do
        opportunity = FactoryGirl.build(:opportunity, buyer: buyer, start_region: "Massachusetts", end_region: "Massachusetts")
        opportunity.companies_to_notify.to_a.should =~ [ma_company, ca_ma_company, national_company]
      end
    end

    context "when regions have changed" do
      it "notifies companies who don't have any of the previous regions" do
        opportunity = FactoryGirl.create(:opportunity, buyer: buyer, start_region: "Massachusetts", end_region: "Massachusetts")
        opportunity.notified_regions.should == ["Massachusetts"]
        opportunity.start_region = "California"
        opportunity.end_region = "California"
        opportunity.companies_to_notify.to_a.should =~ [ca_company]
      end
    end

    context "when opportunity is favorite only" do
      it "notifies to favorited companies" do
        opportunity = FactoryGirl.build(:opportunity, buyer: buyer, for_favorites_only: true)
        opportunity.companies_to_notify.to_a.should =~ [fav_company]
      end
    end

    context "when opportunity was created as favorite only and is changed to not be anymore" do
      it "notifies the companies who have the current regions but not any of the previous regions and are not in the buyers favorites" do
        opportunity = FactoryGirl.create(:opportunity, buyer: buyer, for_favorites_only: true, start_region: "Massachusetts", end_region: "Massachusetts")
        opportunity.for_favorites_only = false
        opportunity.companies_to_notify.to_a.should =~ [ma_company, ca_ma_company, national_company]
      end
    end

    context "when company is locked" do
      it "excludes the company" do
        opportunity = FactoryGirl.build(:opportunity, buyer: buyer, start_region: "Massachusetts", end_region: "Massachusetts")
        opportunity.companies_to_notify.map(&:id).should_not include(locked_company.id)
      end
    end

    context "when company is the poster" do
      it "excludes the company" do
        opportunity = FactoryGirl.build(:opportunity, buyer: buyer, start_region: "Massachusetts", end_region: "Massachusetts")
        opportunity.companies_to_notify.map(&:id).should_not include(buyer.id)
      end
    end

    context "when company does not have the vehicle" do
      it "excludes the company" do
        ma_company.set(:vehicles, ["Sedan"])
        opportunity = FactoryGirl.build(:opportunity, buyer: buyer, start_region: "Massachusetts", end_region: "Massachusetts", vehicle_type: "Bus")
        opportunity.companies_to_notify.to_a.should =~ [ca_ma_company, national_company]
      end
    end
  end

  describe "validate reserve amount and win it now price" do
    context "reverse auction" do
      it "may be valid if reserve amount >= win it now price" do
        FactoryGirl.build(:opportunity, quick_winnable: true, win_it_now_price: 500, reserve_amount: 500).should be_valid
        FactoryGirl.build(:opportunity, quick_winnable: true, win_it_now_price: 500, reserve_amount: 501).should be_valid
      end

      it "is invalid when reserve amount < win it now price" do
        FactoryGirl.build(:opportunity, quick_winnable: true, win_it_now_price: 501, reserve_amount: 500).should_not be_valid
      end
    end

    context "forward auction" do
      it "may be valid if reserve amount <= win it now price" do
        FactoryGirl.build(:forward_auction, quick_winnable: true, win_it_now_price: 500, reserve_amount: 500).should be_valid
        FactoryGirl.build(:forward_auction, quick_winnable: true, win_it_now_price: 501, reserve_amount: 500).should be_valid
      end

      it "is invalid when reserve amount > win it now price" do
        FactoryGirl.build(:forward_auction, quick_winnable: true, win_it_now_price: 500, reserve_amount: 501).should_not be_valid
      end
    end
  end
end

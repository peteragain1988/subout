require 'spec_helper'

describe Bid do
  #describe "validate_opportunity_bidable" do
    #it "is invalid when the opportunity is not biddable by this bidder" do
      #let(:bidder) { FactoryGirl.create(:company) }
      #let(:opportunity) { FactoryGirl.create(:opportunity) }
      #opportunity.stub(:biddable_by?).with(bidder).and_return(false)

      #my_new_bid = FactoryGirl.build(:bid, bidder: bidder, opportunity: opportunity, amount: 101.0)
      #my_new_bid.should_not be_valid
    #end
  #end

  describe "validation" do
    it { should allow_value(1).for(:amount) }
    it { should_not allow_value(0).for(:amount) }
    it { should_not allow_value(-1).for(:amount) }
    it { should ensure_length_of(:comment).is_at_most(255) }
  end

  describe "validate_bidable_by_bidder" do
    let(:buyer) { FactoryGirl.create(:company) }
    let(:bidder) { FactoryGirl.create(:company) }

    context "favorite only opportunity" do
      let(:opportunity) { FactoryGirl.create(:opportunity, buyer: buyer, for_favorites_only: true) }

      it "is not valid if bidder is not added to favorites" do
        FactoryGirl.build(:bid, opportunity: opportunity, bidder: bidder).should_not be_valid
      end

      it "is valid if the bidder is added to favorites" do
        buyer.add_favorite_supplier!(bidder)
        FactoryGirl.build(:bid, opportunity: opportunity, bidder: bidder).should be_valid
      end
    end
  end

  describe "validate_multiple_bids_on_the_same_opportunity" do
    let(:bidder) { FactoryGirl.create(:company) }

    context "reverse auction" do
      let(:opportunity) { FactoryGirl.create(:opportunity) }

      it "is invalid higher price than my previous bids" do
        my_previous_bid = FactoryGirl.create(:bid, bidder: bidder, opportunity: opportunity, amount: 100.0)

        my_new_bid = FactoryGirl.build(:bid, bidder: bidder, opportunity: opportunity, amount: 101.0)
        other_company_bid = FactoryGirl.build(:bid, opportunity: opportunity, amount: 101.0)

        my_new_bid.should_not be_valid
        other_company_bid.should be_valid
      end
    end

    context "forward auction" do
      let(:opportunity) { FactoryGirl.create(:forward_auction) }

      it "is invalid lower price than my previous bids" do
        my_previous_bid = FactoryGirl.create(:bid, bidder: bidder, opportunity: opportunity, amount: 100.0)

        my_new_bid = FactoryGirl.build(:bid, bidder: bidder, opportunity: opportunity, amount: 99.0)
        other_company_bid = FactoryGirl.build(:bid, opportunity: opportunity, amount: 99.0)

        my_new_bid.should_not be_valid
        other_company_bid.should be_valid
      end
    end
  end

  describe "validate_reserve_met" do
    context "reverse auction" do
      let(:opportunity) { FactoryGirl.create(:opportunity, reserve_amount: 1000) }

      it "should be invalid if amount > reserve amount" do
        bid = FactoryGirl.build(:bid, opportunity: opportunity, amount: 1001)
        bid.should_not be_valid
      end
    end

    context "forward auction" do
      let(:opportunity) { FactoryGirl.create(:forward_auction, reserve_amount: 1000) }

      it "should be invalid if amount < reserve amount" do
        bid = FactoryGirl.build(:bid, opportunity: opportunity, amount: 999)
        bid.should_not be_valid
      end
    end
  end

  describe "validate_dot_number_of_bidder" do
    let(:bidder) { FactoryGirl.create(:company, dot_number: "") }
    let(:opportunity) { FactoryGirl.create(:opportunity) }

    it "should be invalid if bidder doesn't have dot number" do
      FactoryGirl.build(:bid, opportunity: opportunity, bidder: bidder).should_not be_valid
    end
  end

  describe "validate_auto_bidding_limit" do
    context "reverse auction" do
      it "auto_bidding_limit should be lower than amount" do
        opportunity = FactoryGirl.create(:opportunity)

        FactoryGirl.build(:bid, opportunity: opportunity, amount: 100, auto_bidding_limit: 99).should be_valid
        FactoryGirl.build(:bid, opportunity: opportunity, amount: 100, auto_bidding_limit: 101).should_not be_valid
      end

      it "auto_bidding_limit should be higher than win_it_now_price" do
        opportunity = FactoryGirl.create(:opportunity, win_it_now_price: 100)

        FactoryGirl.build(:bid, opportunity: opportunity, amount: 200, auto_bidding_limit: 101).should be_valid
        FactoryGirl.build(:bid, opportunity: opportunity, amount: 200, auto_bidding_limit: 99).should_not be_valid
      end
    end

    context "forward auction" do
      it "auto_bidding_limit should be higher than amount" do
        opportunity = FactoryGirl.create(:forward_auction)

        FactoryGirl.build(:bid, opportunity: opportunity, amount: 100, auto_bidding_limit: 101).should be_valid
        FactoryGirl.build(:bid, opportunity: opportunity, amount: 100, auto_bidding_limit: 99).should_not be_valid
      end

      it "auto_bidding_limit should be lower than win_it_now_price" do
        opportunity = FactoryGirl.create(:forward_auction, win_it_now_price: 100)

        FactoryGirl.build(:bid, opportunity: opportunity, amount: 50, auto_bidding_limit: 99).should be_valid
        FactoryGirl.build(:bid, opportunity: opportunity, amount: 50, auto_bidding_limit: 101).should_not be_valid
      end
    end
  end

  describe "run_automatic_bidding" do
    context "reverse auction" do
      let(:opportunity) { FactoryGirl.create(:opportunity) }
      context "when new bid amount is lower than bid amount but higher than auto bidding limit" do
        it "updates bid amount a little lower than new bid amount" do
          old_bid = FactoryGirl.create(:bid, opportunity: opportunity, amount: 800, auto_bidding_limit: 600)
          FactoryGirl.create(:bid, opportunity: opportunity, amount: 700)

          old_bid.reload.amount.to_i.should == 699
        end
      end

      context "when new bid amount is lower than auto bidding limit" do
        it "updates bid amount as auto bidding limit" do
          old_bid = FactoryGirl.create(:bid, opportunity: opportunity, amount: 800, auto_bidding_limit: 600)
          FactoryGirl.create(:bid, opportunity: opportunity, amount: 500)

          old_bid.reload.amount.to_i.should == 600
        end
      end

      context "when new bid amount is higher than bid amount" do
        it "does not update" do
          old_bid = FactoryGirl.create(:bid, opportunity: opportunity, amount: 800, auto_bidding_limit: 600)
          FactoryGirl.create(:bid, opportunity: opportunity, amount: 810)

          old_bid.reload.amount.to_i.should == 800
        end
      end

      context "when new bid has auto_bidding_limit" do
        context "when new bid amount is lower than bid amount but higher than auto bidding limit" do
          it "updates bid amount a little lower than new bid amount" do
            old_bid = FactoryGirl.create(:bid, opportunity: opportunity, amount: 800, auto_bidding_limit: 600)
            new_bid = FactoryGirl.create(:bid, opportunity: opportunity, amount: 750, auto_bidding_limit: 720)

            old_bid.reload.amount.to_i.should == 719
            new_bid.reload.amount.to_i.should == 720
          end
        end

        context "when new bid amount is lower than auto bidding limit" do
          it "updates bid amount as auto bidding limit" do
            old_bid = FactoryGirl.create(:bid, opportunity: opportunity, amount: 800, auto_bidding_limit: 600)
            new_bid = FactoryGirl.create(:bid, opportunity: opportunity, amount: 500, auto_bidding_limit: 400)

            old_bid.reload.amount.to_i.should == 600
            new_bid.reload.amount.to_i.should == 500
          end
        end
      end
    end

    context "forward auction" do
      let(:opportunity) { FactoryGirl.create(:forward_auction) }

      context "when new bid amount is higher than bid amount but lower than auto bidding limit" do
        it "updates bid amount a little higher than new bid amount" do
          old_bid = FactoryGirl.create(:bid, opportunity: opportunity, amount: 800, auto_bidding_limit: 1000)
          FactoryGirl.create(:bid, opportunity: opportunity, amount: 900)

          old_bid.reload.amount.to_i.should == 901
        end
      end

      context "when new bid amount is higher than auto bidding limit" do
        it "updates bid amount as auto bidding limit" do
          old_bid = FactoryGirl.create(:bid, opportunity: opportunity, amount: 800, auto_bidding_limit: 1000)
          FactoryGirl.create(:bid, opportunity: opportunity, amount: 1200)

          old_bid.reload.amount.to_i.should == 1000
        end
      end

      context "when new bid amount is lower than bid amount" do
        it "does not update" do
          old_bid = FactoryGirl.create(:bid, opportunity: opportunity, amount: 800, auto_bidding_limit: 1000)
          FactoryGirl.create(:bid, opportunity: opportunity, amount: 700)

          old_bid.reload.amount.to_i.should == 800
        end
      end

      context "when new bid has auto_bidding_limit" do
        context "when new bid amount is higher than bid amount but lower than auto bidding limit" do
          it "updates bid amount a little higher than new bid amount" do
            old_bid = FactoryGirl.create(:bid, opportunity: opportunity, amount: 800, auto_bidding_limit: 1000)
            new_bid = FactoryGirl.create(:bid, opportunity: opportunity, amount: 920, auto_bidding_limit: 950)

            old_bid.reload.amount.to_i.should == 951
            new_bid.reload.amount.to_i.should == 950
          end
        end

        context "when new bid amount is higher than auto bidding limit" do
          it "updates bid amount as auto bidding limit" do
            old_bid = FactoryGirl.create(:bid, opportunity: opportunity, amount: 800, auto_bidding_limit: 1000)
            new_bid = FactoryGirl.create(:bid, opportunity: opportunity, amount: 1200, auto_bidding_limit: 1300)

            old_bid.reload.amount.to_i.should == 1000
            new_bid.reload.amount.to_i.should == 1200
          end
        end
      end
    end
  end

  describe "validate_has_ada_vehicles_of_bidder" do
    let(:bidder) { FactoryGirl.create(:company, has_ada_vehicles: false) }
    let(:opportunity) { FactoryGirl.create(:opportunity, ada_required: true) }

    it "should be invalid if bidder doesn't have ada vehicles" do
      FactoryGirl.build(:bid, opportunity: opportunity, bidder: bidder).should_not be_valid
    end
  end
  
  describe "cancel" do
    it "should set canceled field as true" do
      bid = FactoryGirl.create(:bid)
      bid.cancel.should be_true
      bid.reload.canceled.should be_true
    end

    it "should not cancel if it's older than 5 mins" do
      bid = FactoryGirl.create(:bid, created_at: 10.minutes.ago)
      bid.cancel.should be_false
      bid.reload.canceled.should be_false
    end
  end
end

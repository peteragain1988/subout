require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Opportunity" do
  let!(:company) { FactoryGirl.create(:company) }
  let!(:user) { FactoryGirl.create(:user, company: company) }
  let!(:opportunity) { FactoryGirl.create(:opportunity, buyer: company) }

  post "/api/v1/auctions.json" do
    parameter :api_token, "Authentication token"
    parameter :name, "Name"
    parameter :type, "Type (Vehicle Needed, Vehicle for Hire, Special, Emergency, Buy or Sell Parts and Vehicles)"
    parameter :description, "Description"
    parameter :start_location, "Original terminal or address"
    parameter :end_location, "Destination"
    parameter :tracking_id, "Internal Memo or ID#"
    parameter :start_date, "Departure date"
    parameter :start_time, "Departure time"
    parameter :end_date, "Arrival date"
    parameter :end_time, "Arrival time"
    parameter :bidding_duration_hrs, "Duration in hours"
    parameter :quick_winnable, "Enable win it now"
    parameter :win_it_now_price, "Win it now price in USD. Required if quick winnable"
    parameter :for_favorites_only, "Limit view to favorite only"
    parameter :forward_auction, "False to buy and true to sell"
    parameter :contact_phone, "Contact phone for emergency opportunity. Required if type is Emergency"

    required_parameters :name, :type, :description, :start_location, :start_date, :start_time,
                        :end_date, :end_time, :bidding_duration_hrs, :api_token

    scope_parameters :opportunity, [:name, :type, :description, :start_location, :end_location,
                                    :tracking_id, :start_date, :start_time, :end_date, :end_time,
                                    :bidding_duration_hrs, :quick_winnable, :win_it_now_price,
                                    :for_favorites_only, :forward_auction, :contact_phone]

    let(:api_token) { user.authentication_token }
    let(:name) { "Coach Bus 49, Brooklyn, NY, 02/22" }
    let(:type) { "Vehicle Needed" }
    let(:description) { "Party Size: 30-40g\nOne Way Miles: 10.6g\nTotal Miles: 43.8g" }
    let(:start_location) { "7912 3rd Avenue, Brooklyn, NY 11209" }
    let(:end_location) { "697 Forest Avenue, Staten Island, NY 10314" }
    let(:tracking_id) { "#102631" }
    let(:start_date) { "2013/02/22" }
    let(:start_time) { "10:00" }
    let(:end_date) { "2013/02/22" }
    let(:end_time) { "22:00" }
    let(:bidding_duration_hrs) { "10" }
    let(:quick_winnable) { false }
    let(:win_it_now_price) { "" }
    let(:for_favorites_only) { false }
    let(:contact_phone) { "" }
    let(:forward_auction) { false }

    context "Reverse auction" do
      example_request "Create Buy" do
        status.should == 201
      end
    end

    context "Forward auction" do
      let(:name) { "Mini Coaches NJ/NY" }
      let(:type) { "Vehicle for Hire" }
      let(:description) { "We have 24 pass to 40 pass Mini Limo available every weekend and most evenings!" }
      let(:forward_auction) { true }

      example_request "Create Sell" do
        status.should == 201
      end
    end

    context "Quick winnable" do
      let(:quick_winnable) { true }
      let(:win_it_now_price) { 1000 }

      example_request "Create Quick Winnable" do
        status.should == 201
      end
    end
  end


  put "/api/v1/auctions/:opportunity_id/cancel.json" do
    parameter :api_token, "Authentication token"
    parameter :opportunity_id, "Opportunity ID"

    let(:api_token) { user.authentication_token }
    let(:opportunity_id) { opportunity.id }

    example_request "Cancel" do
      status.should == 200
    end
  end
end

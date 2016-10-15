When /^I create a new auction$/ do
  create_auction(FactoryGirl.build(:opportunity))
end

When /^I create a new quick winnable auction$/ do
  create_auction(FactoryGirl.build(:opportunity, :quick_winnable => true))
end

When /^I create a new auction for favorites only$/ do
  create_auction(FactoryGirl.build(:opportunity, :for_favorites_only => true))
end

Then /^the auction should have been created$/ do
  click_on "Opportunities"
  find('#modal').should have_content(@auction.name)
end

Then /^a supplier should not be able to \"win it now\"$/ do
  last_opportunity.should_not be_quick_winnable
end

Then /^a supplier should be able to \"win it now\"$/ do
  last_opportunity.should be_quick_winnable
end

Then /^only my favorites should see the opportunity$/ do
  last_opportunity.should be_for_favorites_only
end

Given /^a supplier "(.*?)" has bid on that auction$/ do |name|
  @bidder = @supplier = FactoryGirl.create(:supplier)
  @bid = FactoryGirl.create(:bid, :opportunity => @opportunity, :bidder => @supplier)
end

Given /^I have an auction$/ do
  @auction = FactoryGirl.create(:auction, buyer: @buyer)
end

When /^I view my auctions$/ do
  click_on "Opportunities"
end

Then /^I should see that auction$/ do
  find('#modal').should have_content(@auction.name)
end

Given /^that buyer has a quick winnable auction "(.*?)"$/ do |name|
  @auction = @opportunity = FactoryGirl.create(:quick_winnable_auction, buyer: @buyer, name: name)
end

Given /^that company has a quick winnable forward auction "(.*?)"$/ do |name|
  @auction = @opportunity = FactoryGirl.create(:quick_winnable_auction, buyer: @buyer, name: name, forward_auction: true)
end

When /^I choose that bid as the winner$/ do
  go_to_opportunity_detail

  within("#bid_#{@bid.id}") do
    page.should have_content("Accept")
    click_on "Accept"
  end
end

Then /^that supplier should be notified that they won$/ do
  page.should have_content("Won By #{@supplier.name}")
  step %{"#{@supplier.email}" should receive an email with subject /You won the bidding on #{@auction.name}/}
end

Then /^that (?:auction|opportunity) should (?:show the winning bid|have me as the winner)$/ do  
  page.should have_content("Won By #{@supplier.name}")
  page.should have_content("Winning Bid Amount $#{@auction.reload.winning_bid.amount}")
end

Then /^that (?:auction|opportunity) should (?:show the winning bid|have me as the winner) on detail$/ do
  go_to_opportunity_detail
  
  page.should have_content("Won By #{@supplier.name}")
  page.should have_content("Winning Bid Amount $#{@auction.reload.winning_bid.amount}")
  page.should have_xpath("//*[text()='Accept']", :visible => false)
end

Then /^bidding should be closed on that (?:auction|opportunity)$/ do
  
  page.should have_content("(Closed)")
end

Then /^the (?:buyer|opportunity creator) should be notified that I won that auction$/ do
  page.should have_content("Won By #{@bidder.name}")
  step %{"#{@buyer.email}" should receive an email with subject /#{@bidder.name} has won the bidding on #{@auction.name}/}
end

When /^I cancel the auction$/ do
  go_to_opportunity_detail
  click_on "Cancel"
end

Then /^the auction should be canceled$/ do
  page.should have_content("Canceled by #{@buyer.name}")
  click_on "Opportunities"
  within("#modal") do
    page.should_not have_content @auction.name
  end
end

Given /^that auction has a bid$/ do
  @auction.bids << FactoryGirl.create(:bid)
end

Given /^that auction has some bids$/ do
  @auction.bids << FactoryGirl.create(:bid)
  @auction.bids << FactoryGirl.create(:bid, amount: 10)
end

Then /^I should not be able to cancel that auction$/ do
  go_to_opportunity_detail
  page.should have_xpath("//*[text()='Cancel']", :visible => false)
end

When /^I edit the auction$/ do
  go_to_opportunity_detail

  @new_auction_name = "#{@auction.name} updated"
  click_on "Edit"
  fill_in "Title", with: @new_auction_name
  click_on "Save"
end

When /^the auction is expired$/ do
  Timecop.travel(@auction.bidding_ends + 1.day)

  Event.observers.disable :all do
    Opportunity.send_expired_notification
  end
end

Then /^the action should be updated$/ do
  click_on "Opportunities"
  find('#modal').should have_content(@new_auction_name)
end

Then /^I should not be able to edit that auction$/ do
  go_to_opportunity_detail
  page.should have_xpath("//*[text()='Edit']", :visible => false)
end

Then /^the owner of the auction should be notified$/ do
  sleep(1)
  step %{"#{@buyer.email}" should receive an email with subject /#{@auction.name} is expired/}
end

def last_opportunity
  Opportunity.last
end

def go_to_opportunity_detail
  click_on 'Opportunities'
  
  sleep(1)
  within("#modal") do
    click_on @auction.name
  end
end

def create_auction(opportunity)
  click_link "New Opportunity"

  fill_in "Title", with: opportunity.name
  fill_in "Description", with: opportunity.description
  fill_in "Bidding ends", with: opportunity.bidding_ends
  fill_in "Starting location", with: opportunity.starting_location
  fill_in "Ending location", with: opportunity.ending_location
  fill_in "Start date", with: opportunity.start_date
  fill_in "End date", with: opportunity.end_date
  check "Quick Winnable?" if opportunity.quick_winnable?
  check "For Favorites Only?" if opportunity.for_favorites_only?
  check "Sell?" if opportunity.forward_auction?

  select(opportunity.type, :from => 'Type')

  click_on "Save Opportunity"

  @auction = Opportunity.last
end

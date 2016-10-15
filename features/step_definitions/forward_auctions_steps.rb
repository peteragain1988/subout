Given /^I am signed in as a member company$/ do
  login_as_a_company
end

When /^I want to sell a bus named "(.*?)"$/ do |name|
  create_auction(FactoryGirl.build(:forward_auction, name: name))
end

When /^I bid on that opportunity with amount higher the win it now price$/ do
  do_a_bid(@opportunity.win_it_now_price + 1)
end

def login_as_a_company(password='password1')
  @current_password = password
  @company = FactoryGirl.create(:company)
  @buyer_user = FactoryGirl.create(:user, :password => password, :company => @company)
  sign_in(@buyer_user)

  @company
end

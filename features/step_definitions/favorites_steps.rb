Given /^a supplier exists called "(.*?)"$/ do |name|
  @supplier = FactoryGirl.create(:company, :name => name, :email => 'thomas@bostonbus.com')
end

When /^I add that supplier as one of my favorite suppliers from the supplier's profile$/ do
  click_on @supplier.name

  sleep(0.5)
  #page.should have_content "Add to Favorites"
  click_on "Add to Favorites"
end

Given /^the supplier just had an auction$/ do
  @opportunity = FactoryGirl.create(:opportunity, buyer: @supplier)
end

When /^I find that company to add into my favorite suppliers$/ do
  click_on "Favorites"

  sleep(0.5)
  click_on "Add new Favorite"

  fill_in "supplier_email", :with => @supplier.email
  click_on "Find Supplier"

  page.should have_content @supplier.name
  click_on "Add to Favorites"
end

Then /^that supplier should be in my list of favorite suppliers$/ do
  @buyer.reload.favorite_suppliers.should include(@supplier)
end

Given /^I have "(.*?)" as a favorite supplier$/ do |name|
  @supplier = FactoryGirl.create(:company, :name => name)
  @buyer.add_favorite_supplier!(@supplier)
end

When /^I remove "(.*?)" from my favorites$/ do |name|
  click_on "Favorites"

  sleep(0.5)
  within "#modal" do
    click_on 'Remove'
  end
end

Then /^"(.*?)" should not be in my favorites$/ do |name|
  find('#modal').should_not have_content(name)
end

Then /^that supplier should receive a favorite invitation email$/ do
  sleep(0.5)
  step %["#{@supplier.email}" should receive an email]
end

When /^the supplier accpets the invitation$/ do
  step %{I open the email}
  step %{I click the first link in the email}
end


When /^I try to add "(.*?)" with email "(.*?)" as one of my favorite suppliers but don't find it$/ do |arg1, email|
  click_on "Favorites"

  sleep(0.5)
  click_on "Add new Favorite"

  fill_in "supplier_email", :with => email
  click_on "Find Supplier"

  page.should have_content "That supplier was not found"
end

When /^I add "(.*?)" to my favorites as a new guest supplier with email "(.*?)"$/ do |supplier_name, email|
  click_on "Invite them to join as a guest supplier"

  fill_in 'supplier_name', :with => supplier_name
  find_field('supplier_email').value.should == email
  find_field('message').value.should =~ /#{@buyer.name}/
  fill_in 'message', :with => "Hey Tom, It's Bob.  I'm trying to buy this thing from you.  Please sign up."
  click_on "Send Invitation"

  @favorite_invitation = FavoriteInvitation.last
end

Then /^"(.*?)" should receive a new guest supplier invitation email$/ do |email|
  sleep(0.5)
  step %["#{email}" should receive an email]
end

When /^fills out their supplier details$/ do
  find_field('Company Name').value.should == @favorite_invitation.supplier_name
  find_field('Email').value.should == @favorite_invitation.supplier_email

  fill_in('Password', :with => 'password1') 
  fill_in('Password Confirmation', :with => 'password1') 
  fill_in('Street Address', :with => '33 Comm Ave') 
  fill_in('Zip Code', :with => '02634') 
  fill_in('City', :with => 'New York') 
  fill_in('State', :with => 'New York') 

  click_on('Sign Up')

  @supplier = Company.last
end

When /^I go to see all my favorites list$/ do
  click_on "Favorites"
end

Then /^then I should see the supplier "(.*?)" in the list$/ do |supplier_name|
  find('#modal').should have_content(supplier_name)
end

Then /^that supplier be able to sign in$/ do
  user = @supplier.users.first
  user.password = "password1"

  sign_in(user)
end

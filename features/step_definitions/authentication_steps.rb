When /^I change my password$/ do
  @new_password = "password2"
  click_on "Settings"
  fill_in "Current Password", with: @current_password
  fill_in "New Password", with: @new_password
  fill_in "Password Confirmation", with: @new_password
  click_on "Save"
end

Then /^I should be able to login with my new password$/ do
  fill_in "Email", with: @buyer_user.email
  fill_in "Password", with: @new_password
  click_on "Sign In"

  page.should have_content("signed in as")
end

Given /^I am signed out$/ do
  click_on "Sign Out"
end

When /^I sign out$/ do
  click_on "Sign Out"
end

When /^I reset my password$/ do
  click_on "Forgot the password?"
  fill_in "Email", with: @buyer_user.email
  click_on "Send Reset Link"

  sleep 1
  token = @buyer_user.reload.reset_password_token
  visit "/#/password/edit?reset_password_token=#{token}"

  @new_password = 'password3'
  fill_in "password", with: @new_password
  fill_in "Password Confirmation", with: @new_password
  click_on "Reset my password"

  page.should have_content("Your password is reset successfully")
end


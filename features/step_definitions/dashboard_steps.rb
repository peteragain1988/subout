Given /^some events exists$/ do
  FactoryGirl.create_list(:event, 20)
end

Then /^I should see recent events$/ do
  page.should have_selector('tr.event')
end

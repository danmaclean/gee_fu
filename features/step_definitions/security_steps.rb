Given(/^I am not logged in$/) do
  # dummy step
end

Given(/^there are no users$/) do
  # for now a dummy step
  # User.count.should eq 0
  # Admin.count.should eq 0
end

Then(/^I should be able to sign up$/) do
  click_link "Sign up"
end

When(/^I sign up as "(.*?)" with email "(.*?)"$/) do |name, email|
  full_name = name.split(" ")
  fill_in "First name", :with => full_name[0]
  fill_in "Last name", :with => full_name[1]
  fill_in "Email address", :with => email
  fill_in "Password", :with => "password"
  fill_in "Confirm your password", :with => "password"
  click_button "Sign up"
end

Then(/^"(.*?)" should be a confirmed user$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

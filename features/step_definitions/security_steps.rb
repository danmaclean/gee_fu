Given(/^I am not logged in$/) do
  visit "/users/sign_out"
end

Given(/^there are no users$/) do
  User.count.should eq 0
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
  fill_in "Password confirmation", :with => "password"
  click_button "Sign up"
end

Then(/^"(.*?)" should be a confirmed user$/) do |email|
  User.where(:email => email).first.should be_confirmed
end

Given(/^there is a user called "(.*?)" with email "(.*?)"$/) do |name, email|
  full_name = name.split(" ")
  user = User.new(
    email:                  email,
    password:               "password",
    password_confirmation:  "password",
    first_name:             full_name[0],
    last_name:              full_name[1]
  )
  user.confirm!
  user.save!
end

Given(/^"(.*?)" is logged in$/) do |email|
  visit "/users/sign_in"
  fill_in "Email address", with: email
  fill_in "Password", with: "password"
  click_button "Sign in"
end

Then(/^I should be able to sign out$/) do
  click_link "Sign Out"
end

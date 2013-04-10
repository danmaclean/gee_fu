Given(/^I am not logged in$/) do
  visit "/users/sign_out"
end

Given(/^there are no users$/) do
  User.count.should eq 0
end

Then(/^I should be able to sign up$/) do
  ->{find "a", text: "Sign up"}.should_not raise_exception
end

When(/^I sign up as "(.*?)" with email "(.*?)"$/) do |name, email|
  complete_sign_up_form_with(name, email)
  click_button "Sign up"
end

When(/^I sign up as "(.*?)" with place of work "(.*?)" and role "(.*?)" and email "(.*?)"$/) do |name, place_of_work, role, email|
  complete_sign_up_form_with(name, email)
  fill_in "Affiliation / Place of work", :with => place_of_work
  fill_in "Role", :with => role
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
  set_current_user_email(email)
  fill_in "Email address", with: email
  fill_in "Password", with: "password"
  click_button "Sign in"
end

Then(/^I should be able to sign out$/) do
  ->{find "a", text: "Sign Out"}.should_not raise_exception
end

When(/^I edit my name to "(.*?)"$/) do |name|
  full_name = name.split(" ")
  fill_in "First name", :with => full_name[0]
  fill_in "Last name", :with => full_name[1]
  fill_in "Current password", :with => "password"
  click_button "Update"
end

Then(/^my name should be "(.*?)"$/) do |name|
  full_name = name.split(" ")
  current_user.first_name.should eq full_name[0]
  current_user.last_name.should eq full_name[1]
end

When(/^"(.*?)" confirms the account$/) do |email|
  step %Q{"#{email}" should receive an email}
  step %Q{I open the email}
  step %Q{I click the first link in the email}
end

Then(/^I should have a place of work "(.*?)" and role "(.*?)"$/) do |place_of_work, role|
  current_user.affiliation.should eq place_of_work
  current_user.role.should eq role
end

When(/^I edit my place of work to "(.*?)"$/) do |place_of_work|
  fill_in "Affiliation / Place of work", :with => place_of_work
  fill_in "Current password", :with => "password"
  click_button("Update")
end

Then(/^my place of work should be "(.*?)"$/) do |place_of_work|
  current_user.affiliation.should eq place_of_work
end

When(/^I edit my role to "(.*?)"$/) do |role|
  fill_in "Role", :with => role
  fill_in "Current password", :with => "password"
  click_button("Update")
end

Then(/^my role should be "(.*?)"$/) do |role|
  current_user.role.should eq role
end

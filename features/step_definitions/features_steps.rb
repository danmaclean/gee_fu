When(/^I am ready to review features directly$/) do
  visit "/features"
end

Given(/^I am reviewing features$/) do
  click_link "Features"
end

Given(/^I am reviewing a feature$/) do
  click_link "Features"
  step %Q{I search by feature ID}
end

When(/^I search by feature ID$/) do
  within "div#find_feature_by_id" do
    fill_in "Database ID", :with => Feature.first.id
    click_button "Search"
  end
end

Then(/^I should see the genome feature for that ID$/) do
  # TODO - use a better way to determine the content
  page.should have_content JSON.parse(Feature.first.group).join(' ')
end

When(/^I edit a feature and change the coordinates of the exon$/) do
  click_link Feature.first.id
  fill_in "Start Position", with: 1000
  fill_in "End Position", with: 2000
  click_button "Update Feature"
end

Then(/^there should be a new feature with changed coordinates$/) do
  Feature.last.start.should eq 1000
  Feature.last.end.should eq 2000
end

When(/^I search by attribute "(.*?)"$/) do |attribute|
  within "div#find_feature_by_attribute" do
    fill_in "Enter string to find", with: attribute
    click_button "Search"
  end
end
  
Then(/^I should see features with the attribute "(.*?)"$/) do |attribute|
  page.should have_content attribute
end

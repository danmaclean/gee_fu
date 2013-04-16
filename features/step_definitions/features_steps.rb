Given(/^I am reviewing features$/) do
  click_link "Features"
end

When(/^I search by feature ID$/) do
  within "div#find_feature_by_id" do
    fill_in "Database ID", :with => Feature.first.id
    click_button "Get feature"
  end
end

Then(/^I should see the genome feature for that ID$/) do
  # TODO - use a better way to determine the content
  page.should have_content JSON.parse(Feature.first.group).join(' ')
end

When(/^I am ready to review features directly$/) do
  visit "/features"
end

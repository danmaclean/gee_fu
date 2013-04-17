Given /^there are no organisms$/ do
  Organism.count.should == 0
end

When /^I am ready to add an organism$/ do
  click_link 'Samples'
  click_link 'New organism'
end

Then /^there should be (\d+) organism$/ do |number_of_organisms|
  Organism.count.should == number_of_organisms.to_i
end

When /^I add an organism of the "([^"]*)" genus and the "([^"]*)" species$/ do |genus, species|
  fill_in "Genus (required)",   :with => genus 
  fill_in "Species (required)", :with => species 
  click_button "Create"
end

Then /^the organism should be of the "([^"]*)" genus and the "([^"]*)" species$/ do |genus, species|
  Organism.last.genus.should   == genus
  Organism.last.species.should == species
end

Then /^I should see the newly created organism of the "([^"]*)" genus and the "([^"]*)" species$/ do |genus, species|
  page.should have_content "Organism was successfully created"
  page.should have_content genus
  page.should have_content species
end

When(/^I try to add an organism directly$/) do
  visit "/organisms"
end

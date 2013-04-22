Given /^there are no organisms$/ do
  Organism.count.should == 0
end

When /^I am ready to add an organism$/ do
  click_link 'Samples'
  click_link 'New organism'
end

Then /^there should be (\d+) organism(?:s)?$/ do |number_of_organisms|
  Organism.count.should == number_of_organisms.to_i
end

When(/^I add an organism of the "(.*?)" genus and the "(.*?)" species with "(.*?)" taxonomy id and "(.*?)" strain and "(.*?)" as the local name$/) do |genus, species, taxonomy, strain, local_name|
  fill_in "Genus (required)",   :with => genus 
  fill_in "Species (required)", :with => species 
  fill_in "Strain (required)", :with => strain
  fill_in "NCBI taxonomy ID (required)", :with => taxonomy
  fill_in "Local name (required)", :with => local_name
  click_button "Create"
end

Then(/^the organism should be of the "(.*?)" genus and the "(.*?)" species with "(.*?)" taxonomy id and "(.*?)" strain and "(.*?)" as the local name$/) do |genus, species, taxonomy, strain, local_name|
  organism = Organism.last
  organism.genus.should   == genus
  organism.species.should == species
  organism.taxid.should == taxonomy.to_i
  organism.strain.should == strain
  organism.local_name.should == local_name
end

Then /^I should see the newly created organism of the "([^"]*)" genus and the "([^"]*)" species$/ do |genus, species|
  page.should have_content "Organism was successfully created"
  page.should have_content genus
  page.should have_content species
end

When(/^I try to add an organism directly$/) do
  visit "/organisms"
end

Given(/^there is an organism with local name of "(.*?)"$/) do |local_name|
  Organism.create!(
    local_name: local_name,
    genus: "Arabidposis",
    species: "thalian",
    strain: "Col 0",
    taxid: "3702"
  )
end

Given(/^there are no genome builds$/) do
  Genome.count.should == 0
end

When(/^I am ready to add a genome build$/) do
  visit "/begin"
  click_link "Genome Builds"
  click_link "New genome"
end

When(/^I add a genome build called "(.*?)" with Fasta file "(.*?)" and YAML file of "(.*?)"$/) do |name, fasta_file, config_file|
  fill_in "Build version (required)", :with => name
  attach_file "Fasta file of sequences (required)", "#{Rails.root}/#{fasta_file}"
  attach_file "YAML file of metadata about this genome (required for AnnoJ browsing only)", "#{Rails.root}/#{config_file}"
  click_button "Create"
end

Then(/^there should be a genome build called "(.*?)"$/) do |name|
  Genome.first.build_version.should eq name
end

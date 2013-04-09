Given(/^there are no genome builds$/) do
  Genome.count.should == 0
end

When(/^I am ready to add a genome build$/) do
  visit "/begin"
  click_link "Genome Builds"
  click_link "New genome"
end

When(/^I add a genome build called "(.*?)" with Fasta file "(.*?)" and YAML file of "(.*?)"$/) do |name, fasta_file, config_file|
  add_genome_build(name, fasta_file, config_file)
end

Then(/^there should be a genome build called "(.*?)"$/) do |name|
  Genome.where(:build_version => name).count.should eq 1
end

Given(/^there is a genome build called "(.*?)" with Fasta file "(.*?)" and YAML file of "(.*?)"$/) do |genome_build, fasta_file, config_file|
  Genome.where(:build_version => genome_build).count.should eq 0
  step %Q{I am ready to add a genome build}
  add_genome_build(genome_build, fasta_file, config_file)
  Genome.where(:build_version => genome_build).count.should eq 1
end

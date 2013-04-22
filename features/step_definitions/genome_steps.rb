Given(/^there are no genome builds$/) do
  Genome.count.should == 0
end

When(/^I am ready to add a genome build$/) do
  click_link "Genome Builds"
  click_link "New genome"
end

When(/^I add a genome build called "(.*?)" with Fasta file "(.*?)" and YAML file of "(.*?)" for the "(.*?)" organism$/) do |name, fasta_file, config_file, organism|
  add_genome_build(organism, name, fasta_file, config_file)
end

Then(/^there should be a genome build called "(.*?)" for the "(.*?)" organism$/) do |name, organism|
  organism = Organism.where{ local_name.eq(organism) }.first
  Genome.where(:organism_id => organism.id, :build_version => name).count.should eq 1
end

Given(/^there is a genome build called "(.*?)" with Fasta file "(.*?)" and YAML file of "(.*?)" for the organism "(.*?)"$/) do |genome_build, fasta_file, config_file, organism|
  Genome.where(:build_version => genome_build).count.should eq 0
  step %Q{I am ready to add a genome build}
  add_genome_build(organism, genome_build, fasta_file, config_file)
  Genome.where(:build_version => genome_build).count.should eq 1
end

When(/^I try to add a genome directly$/) do
  visit "/genomes"
end

Then(/^I should not be able to add a genome build$/) do
  ->{find "a", text: "Genome Builds"}.should raise_exception
end

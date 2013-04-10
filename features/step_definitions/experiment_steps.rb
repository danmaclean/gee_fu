Given(/^there is no experiment data$/) do
  Experiment.count.should eq 0
end

When(/^I am ready to enter experiment data$/) do
  click_link("Annotation Experiments")
  click_link("New experiment")
end

When(/^I add an experiment called "(.*?)", described as "(.*?)" with GFF file "(.*?)" and "(.*?)" as the genome build$/) do |name, description, gff_file, genome_build|
  within "div#gff_experiment_data" do
    fill_in("name (required)", :with => name)
    fill_in("description (required)", :with => description)
    attach_file("GFF3 file of features (required)", "#{Rails.root}/#{gff_file}")
    choose(genome_build)
    click_button "Create"
  end
end

Then(/^there should be an experiment called "(.*?)"$/) do |name|
  Experiment.where(:name => name).count.should eq 1
end

When(/^I am ready to enter experiment data directly$/) do
  visit "/experiments"
end

When(/^I add an experiment called "(.*?)", described as "(.*?)" with BAM file "(.*?)" and "(.*?)" as the genome build$/) do |name, description, bam_file, genome_build|
  within "div#bam_experiment_data" do
    fill_in("name (required)", :with => name)
    fill_in("description (required)", :with => description)
    attach_file("BAM file of features (required)", "#{Rails.root}/#{bam_file}")
    choose(genome_build)
    click_button "Create"
  end
end
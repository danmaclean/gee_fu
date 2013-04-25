When(/^I am ready to extract sequence data$/) do
  click_link "Tools"
end

When(/^I extract the "(.*?)" sequence starting at "(.*?)" and ending at "(.*?)" with "(.*?)" strand for the "(.*?)" genome build$/) do |sequence, starting, ending, strand, genome_build|
  select genome_build, from: :genome_id
  fill_in "reference", with: sequence
  fill_in "start", with: starting
  fill_in "end", with: ending
  select strand, from: :strand
  click_button "Extract sequence"
end

Then(/^I should see the extracted sequence$/) do
  page.should have_content ">Chr1 1000..2000 +"
end

When(/^I am ready to extract sequence data directly$/) do
  visit "/tools"
end

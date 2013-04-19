When(/^I am ready to extract sequence data$/) do
  click_link "Tools"
end

When(/^I extract the "(.*?)" sequence starting at "(.*?)" and ending at "(.*?)" with "(.*?)" strand for the "(.*?)" genome build$/) do |sequence, starting, ending, strand, genome_build|
  choose genome_build
  fill_in "reference", with: sequence
  fill_in "start", with: starting
  fill_in "end", with: ending
  if strand == "+"
    choose "strand__"
  else
    choose "strand_-"
  end
  click_button "extract this sequence"
end

Then(/^I should see the extracted sequence$/) do
  page.should have_content ">Chr1 1000..2000 +"
end

When(/^I am ready to extract sequence data directly$/) do
  visit "/tools"
end

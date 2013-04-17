When(/^I am ready to extract sequence data$/) do
  click_link "Tools"
end

When(/^I extract the "(.*?)" sequence starting at "(.*?)" and ending at "(.*?)" with "(.*?)" strand$/) do |sequence, starting, ending, strand|
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
  pending # express the regexp above with the code you wish you had
end

When(/^I am ready to extract sequence data directly$/) do
  visit "/tools"
end

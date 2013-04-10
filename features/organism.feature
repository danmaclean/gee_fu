Feature: Entering organism data
  In order to analyse organisms
  As a scientist
  I want to be able to add organisms

Scenario: Add an organism
  Given there are no organisms
  And there is a user called "Fred Bloggs" with email "fred@fred.com"
  And "fred@fred.com" is logged in
  When I am ready to add an organism
  And I add an organism of the "Arabidposis" genus and the "thalian" species 
  Then there should be 1 organism
  And the organism should be of the "Arabidposis" genus and the "thalian" species
  And I should see the newly created organism of the "Arabidposis" genus and the "thalian" species

Scenario: Try to add an organism when not logged in
  Given there are no organisms
  And I am not logged in
  When I try to add an organism directly
  Then I should be on the sign in page
  And I should see "You need to sign in or sign up before continuing."

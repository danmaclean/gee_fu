Feature: Entering organism data
  In order to analyse organisms
  As a scientist
  I want to be able to add organisms

Scenario: Add an organism
  Given there are no organisms
  When I am ready to add an organism
  And I add an organism of the "Arabidposis" genus and the "thalian" species 
  Then there should be 1 organism
  And the organism should be of the "Arabidposis" genus and the "thalian" species
  And I should see the newly created organism of the "Arabidposis" genus and the "thalian" species
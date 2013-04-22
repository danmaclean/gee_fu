Feature: Entering organism data
  In order to analyse organisms
  As a scientist
  I want to be able to add organisms

  Scenario: Add an organism
    Given there are no organisms
    And there is a user called "Fred Bloggs" with email "fred@fred.com"
    And "fred@fred.com" is an admin user
    And "fred@fred.com" is logged in
    When I am ready to add an organism
    And I add an organism of the "Arabidposis" genus and the "thalian" species with "3702" taxonomy id and "A" strain and "My favourite organism" as the local name
    Then there should be 1 organism
    And the organism should be of the "Arabidposis" genus and the "thalian" species with "3702" taxonomy id and "A" strain and "My favourite organism" as the local name
    And I should see the newly created organism of the "Arabidposis" genus and the "thalian" species

  Scenario: Try to add an organism when not an admin user
    Given there are no organisms
    And there is a user called "Fred Bloggs" with email "fred@fred.com"
    And "fred@fred.com" is logged in
    Then I should not see "Samples"
    When I try to add an organism directly
    Then I should be on the home page
    And I should see "You have been signed out for security reasons."

  Scenario: Try to add an organism when not logged in
    Given there are no organisms
    And I am not logged in
    When I try to add an organism directly
    Then I should be on the sign in page
    And I should see "You need to sign in or sign up before continuing."

  Scenario: Try to add an organism without a required field
    And there is a user called "Fred Bloggs" with email "fred@fred.com"
    And "fred@fred.com" is an admin user
    And "fred@fred.com" is logged in
    When I am ready to add an organism
    And I add an organism of the "Arabidposis" genus and the "thalian" species with "" taxonomy id and "" strain and "" as the local name
    Then there should be 0 organisms


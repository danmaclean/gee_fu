Feature: Entering genome data
  In order to analyse genome data
  As a scientist
  I want to be able to add genome builds

  Scenario: Add a genome build when logged in
    Given there are no genome builds
    And there is a user called "Fred Bloggs" with email "fred@fred.com"
    And "fred@fred.com" is logged in
    When I am ready to add a genome build
    And I add a genome build called "TAIR 9" with Fasta file "public/sequences/sample_reference_TAIR9_Chr1.fna" and YAML file of "config/meta.yml"
    Then there should be a genome build called "TAIR 9"

  Scenario: Add a genome build when not logged in
    Given there are no genome builds
    And I am not logged in
    When I try to add a genome directly
    Then I should be on the sign in page
    And I should see "You need to sign in or sign up before continuing."

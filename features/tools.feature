Feature: Use the GeeFu tools
  In order to extract sequence data
  As a Scientist
  I want to use automated tools to help me

  Scenario: Extract a genome sequence
    Given there is a user called "Fred Bloggs" with email "fred@fred.com"
    And there is an organism with local name of "My favourite organism"
    And "fred@fred.com" is logged in
    And there is a genome build called "TAIR 9" with Fasta file "public/sequences/short.fna" and YAML file of "config/meta.yml" for the organism "My favourite organism"
    When I am ready to extract sequence data
    And I extract the "Chr1" sequence starting at "1000" and ending at "2000" with "+" strand for the "TAIR 9" genome build
    Then I should see the extracted sequence

  Scenario: Extract a genome sequence when not logged in
    Given I am not logged in
    When I am ready to extract sequence data directly
    Then I should be on the sign in page
    And I should see "You need to sign in or sign up before continuing."

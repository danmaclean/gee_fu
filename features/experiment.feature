Feature: Add experiment data
  In order to experiment on genome date
  As a Scientist
  I want to add experiment data

  Scenario: Add experiment data from a GFF file when logged in
    Given there is no experiment data
    And there is a user called "Fred Bloggs" with email "fred@fred.com"
    And "fred@fred.com" is logged in
    And there is a genome build called "TAIR 9" with Fasta file "public/sequences/sample_reference_TAIR9_Chr1.fna" and YAML file of "config/meta.yml"
    When I am ready to enter experiment data
    And I add an experiment called "TAIR experiment", described as "my first experiment" with GFF gile "public/sample_gffs/sample_features.gff" and "TAIR 9" as the genome build
    Then there should be an experiment called "TAIR experiment"

  Scenario: Add experiment data from a GFF file when not logged in
    Given there is no experiment data
    And I am not logged in
    When I am ready to enter experiment data directly
    Then I should be on the sign in page
    And I should see "You need to sign in or sign up before continuing."
  
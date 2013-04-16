Feature: Review genome features
  In order to review on genome feature data
  As a Scientist
  I want to see specific feature data

  Scenario: Review feature data by ID as logged in user
    Given there is a user called "Fred Bloggs" with email "fred@fred.com"
    And "fred@fred.com" is logged in
    And there is a genome build called "TAIR 9" with Fasta file "public/sequences/sample_reference_TAIR9_Chr1.fna" and YAML file of "config/meta.yml"
    And there is an experiment called "TAIR experiment", described as "my first experiment" with GFF file "public/sample_gffs/sample_features.gff" and "TAIR 9" as the genome build
    And I am reviewing features
    When I search by feature ID 
    Then I should see the genome feature for that ID

  Scenario: Cannot review features unless logged in
    Given I am not logged in
    When I am ready to review features directly
    Then I should be on the sign in page
    And I should see "You need to sign in or sign up before continuing."

  Scenario: Edit a genome feature
    Given there is a user called "Fred Bloggs" with email "fred@fred.com"
    And "fred@fred.com" is logged in
    And there is a genome build called "TAIR 9" with Fasta file "public/sequences/sample_reference_TAIR9_Chr1.fna" and YAML file of "config/meta.yml"
    And there is an experiment called "TAIR experiment", described as "my first experiment" with GFF file "public/sample_gffs/sample_features.gff" and "TAIR 9" as the genome build
    And I am reviewing a feature
    When I edit a feature and change the coordinates of the exon
    Then I should see "New feature was successfully created."
    And there should be a new feature with changed coordinates

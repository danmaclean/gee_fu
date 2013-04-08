Feature: Entering genome data
  In order to analyse genome data
  As a scientist
  I want to be able to add genome builds

Scenario: Add a genome build
  Given there are no genome builds
  When I am ready to add a genome build
  And I add a genome build called "TAIR 9" with Fasta file "public/sequences/sample_reference_TAIR9_Chr1.fna" and YAML file of "config/meta.yml"
  Then there should be a genome build called "TAIR 9"

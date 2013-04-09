Feature: Security for data editing
  So that data is secure
  As a Scientist
  I want have to sign in as a user to edit data

  @wip
  Scenario: User signs up for GeeFu
    Given I am not logged in
    And there are no users
    When I am on the home page for editing data
    Then I should be able to sign up
    When I sign up as "Fred Bloggs" with email "fred@fred.com"
    Then "fred@fred.com" should receive an email
    When I open the email
    And I follow "Confirm your account" in the email
    Then I should see "Welcome to GeeFu"
    And "fred@fred.com" should be a confirmed user

  
  

  

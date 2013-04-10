Feature: Security for data editing
  So that data is secure
  As a Scientist
  I want have to sign in as a user to edit data

  Scenario: User signs up for GeeFu
    Given I am not logged in
    And there are no users
    When I am on the home page
    Then I should be able to sign up
    When I sign up as "Fred Bloggs" with email "fred@fred.com"
    Then I should be on the user signup page
    And I should see " An email is on its way with instructions on how to confirm your account."
    And "fred@fred.com" should receive an email
    When I open the email
    And I click the first link in the email
    Then I should be on the home page
    And "fred@fred.com" should be a confirmed user

  Scenario: User signs up for GeeFu with an place of work and role
    Given I am not logged in
    And there are no users
    When I am on the home page
    When I sign up as "Fred Bloggs" with place of work "The Sainsbury Laboratory" and role "Scientist" and email "fred@fred.com"
    And "fred@fred.com" confirms the account
    Then I should have a place of work "The Sainsbury Laboratory" and role "Scientist"

  Scenario: User sees correct navigation if not signed in
      Given there is a user called "Fred Bloggs" with email "fred@fred.com"
      And I am not logged in
      When I am on the home page
      Then I should see "You need to sign in (or sign up) before you can access the data."
      And I should be able to sign up

  Scenario: User sees correct navigation if signed in
      Given there is a user called "Fred Bloggs" with email "fred@fred.com"
      And "fred@fred.com" is logged in
      When I am on the home page
      Then I should see "Use the links above to edit the data."
      And I should be able to sign out
    
  Scenario: User can update their name
      Given there is a user called "Fred Bloggs" with email "fred@fred.com"
      And "fred@fred.com" is logged in
      When I am on the account page
      And I edit my name to "Frederick Blogger"
      Then my name should be "Frederick Blogger"

  Scenario: User can update their place of work
      Given there is a user called "Fred Bloggs" with email "fred@fred.com"
      And "fred@fred.com" is logged in
      When I am on the account page
      And I edit my place of work to "The Asda Lab"
      Then my place of work should be "The Asda Lab"

  Scenario: User can update their role
      Given there is a user called "Fred Bloggs" with email "fred@fred.com"
      And "fred@fred.com" is logged in
      When I am on the account page
      And I edit my role to "Student"
      Then my role should be "Student"

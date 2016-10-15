Feature: Buyer create a new auction
  As a buyer
  I want to create a auction
  So I can buy what I need

  @javascript
  Scenario: buyer creates a auction
    Given I am signed in as a buyer
    When I create a new auction
    Then the auction should have been created
    And a supplier should not be able to "win it now"

  @javascript
  Scenario: creates an auction for favorites only
    Given I am signed in as a buyer
    When I create a new auction for favorites only
    Then the auction should have been created
    And only my favorites should see the opportunity

  @javascript
  Scenario: buyer creates a quick winnable auction
    Given I am signed in as a buyer
    When I create a new quick winnable auction
    Then the auction should have been created
    And a supplier should be able to "win it now"


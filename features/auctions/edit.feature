Feature: Edit an auction

  @javascript
  Scenario: I want to edit an opportunity I created
    Given I am signed in as a buyer
    And I have an auction
    When I edit the auction
    Then the action should be updated

  @javascript
  Scenario: I should not be able to edit an oppotunity with a bid
    Given I am signed in as a buyer
    And I have an auction
    And that auction has a bid
    Then I should not be able to edit that auction

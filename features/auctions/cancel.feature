Feature: 
  As a buyer 
  I want to cancel an auction before the first bid 
  because I changed my mind about buying this thing.

  @javascript
  Scenario: Cancel an opportunity
    Given I am signed in as a buyer
    And I have an auction
    When I cancel the auction
    Then the auction should be canceled

  @javascript
  Scenario: Can't cancel after the first bid
    Given I am signed in as a buyer
    And I have an auction
    And that auction has a bid
    Then I should not be able to cancel that auction

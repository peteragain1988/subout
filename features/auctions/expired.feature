Feature: Expired auction

  @javascript
  Scenario:
    Given I am signed in as a buyer
    And I have an auction
    And that auction has some bids
    When the auction is expired
    Then the owner of the auction should be notified

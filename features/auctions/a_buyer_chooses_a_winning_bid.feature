Feature: A buyer chooses a winning bid

  @javascript
  Scenario:
    Given I am signed in as a buyer "Boston Bus"
    And I have an auction "Boston to New York Charter"
    And a supplier "New York Bus" has bid on that auction
    When I choose that bid as the winner
    Then that supplier should be notified that they won
    And that auction should show the winning bid on detail
    And bidding should be closed on that auction

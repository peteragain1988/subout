Feature: A company does a quick win on a forward auction

  @javascript
  Scenario: A bidder uses the 'win it now' button
    Given a company exists "Boston Bus"
    And that company has a quick winnable forward auction "Boston to New York Charter"
    And I am logged in as a member company "New York Bus"
    When I do a quick win on that opportunity
    Then the opportunity creator should be notified that I won that auction
    And that opportunity should have me as the winner

  @javascript
  Scenario: A bidder bids higher the win it now price
    Given a company exists "Boston Bus"
    And that company has a quick winnable forward auction "Boston to New York Charter"
    And I am logged in as a member company "New York Bus"
    When I bid on that opportunity with amount higher the win it now price
    Then I should win that opportunity automatically

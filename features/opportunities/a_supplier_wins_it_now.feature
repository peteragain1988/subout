Feature: A supplier does a quick win

  @javascript
  Scenario: A supplier uses the 'win it now' button
    Given a buyer exists "Boston Bus"
    And that buyer has a quick winnable auction "Boston to New York Charter"
    And I am logged in as a member supplier "New York Bus"
    When I do a quick win on that opportunity
    Then the buyer should be notified that I won that auction
    And that opportunity should have me as the winner

  @javascript
  Scenario: A supplier bids below the win it now price
    Given a buyer exists "Boston Bus"
    And that buyer has a quick winnable auction "Boston to New York Charter"
    And I am logged in as a member supplier "New York Bus"
    When I bid on that opportunity with amount below the win it now price
    Then I should win that opportunity automatically

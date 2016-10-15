Feature:

  @javascript
  Scenario: I want to bid on a forward auction
    Given a company exists "Boston Bus"
    And that company has an auction "Mack Bus 1000"
    And I am signed in as a member company
    When I bid on that opportunity
    Then I should see my bid on that opportunity
    And the company should be notified about my bid

Feature: Create a new forward auction

  @javascript
  Scenario: I have a bus I want to see to the highest bidder
    Given I am signed in as a member company
    When I want to sell a bus named "Mack Bus 1000"
    Then the auction should have been created

Feature: Dashboard

  @javascript
  Scenario: A user view recent events
    Given some events exists
    And I am signed in as a buyer
    Then I should see recent events

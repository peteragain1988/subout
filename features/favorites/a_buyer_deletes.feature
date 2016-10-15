Feature: A buyer deletes a supplier from their list of favorites

  @javascript
  Scenario:
    Given I am signed in as a buyer
    And I have "Boston Bus" as a favorite supplier
    When I remove "Boston Bus" from my favorites
    Then "Boston Bus" should not be in my favorites

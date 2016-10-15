Feature: A buyer view thier list of favorite companies

  @javascript
  Scenario:
    Given I am signed in as a buyer
    And I have "Boston Bus" as a favorite supplier
    When I go to see all my favorites list
    Then then I should see the supplier "Boston Bus" in the list

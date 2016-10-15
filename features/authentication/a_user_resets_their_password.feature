Feature: A user resets their password feature

  @javascript
  Scenario:
    Given I am signed in as a buyer "Boston Bus"
    And I am signed out
    When I reset my password
    Then I should be able to login with my new password

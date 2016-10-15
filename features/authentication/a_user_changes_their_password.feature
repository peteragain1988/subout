Feature: A user changes their password feature
  @javascript
  Scenario:
    Given I am signed in as a buyer "Boston Bus"
    When I change my password
    And I sign out
    Then I should be able to login with my new password

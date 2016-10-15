Feature: A supplier bids

  @javascript
  Scenario: A member supplier bids on an opportunity
    Given a buyer exists "Boston Bus"
    And that buyer has an auction "Boston to New York Charter"
    And I am logged in as a member supplier "New York Bus"
    When I bid on that opportunity
    Then I should see my bid on that opportunity
    And the buyer should be notified about my bid

  @javascript
  Scenario: A supplier can't bid again on the same opportunity with higher price
    Given a buyer exists "Boston Bus"
    And that buyer has an auction "Boston to New York Charter"
    And I am logged in as a member supplier "New York Bus"
    When I bid on that opportunity
    Then I cannot bid again that opportunity with higher price

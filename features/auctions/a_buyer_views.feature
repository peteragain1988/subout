Feature: Buyer views their auctions
  As a buyer
  I want to view my auctions
  So I can see the bids

  @javascript
  Scenario: Buyer views an auction
    Given I am signed in as a buyer
    And I have an auction
    When I view my auctions
    Then I should see that auction

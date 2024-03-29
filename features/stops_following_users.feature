@javascript
Feature: Unfollowing
  In order to stop seeing updates from self-important rockstars
  As a user
  I want to be able to stop following people

  Background:
    Given following users:
		| email             |
		| bob@bob.bob       |
		| alice@alice.alice |
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    And I add the person to my "Besties" group

  Scenario: stop following someone while on their profile page
    When I am on "alice@alice.alice"'s page

    And I remove the person from my "Besties" group
    And I am on the home page

    Then I should have 0 followers in "Besties"

    Then I go to the destroy user session page
    When I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page

    Then I should not see "is sharing with you."

  Scenario: stop following someone while on the group edit page
    When I go to the home page
    And I go to the followers page

    And I follow "Besties"
    And I follow "add followers to Besties"
    And I wait for the ajax to finish

    And I preemptively confirm the alert
    And I press the first ".added" within "#facebox .follower_list ul > li:first-child"
    And I wait for the ajax to finish

    When I follow "My Followers"
    Then I should have 0 followers in "Besties"

    When I go to the destroy user session page
    And I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page
    Then I should not see "is sharing with you."

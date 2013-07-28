@groups @javascript
Feature: User manages followers
  In order to share with a limited group
  As a User
  I want to create new groups

  Scenario: creating an group from followers index
    Given I am signed in
    And I am on the followers page
    And I follow "+ Add an group"
    And I fill in "Name" with "Dorm Mates" in the modal window
    And I press "Create" in the modal window
    Then I should see "Dorm Mates" within "#group_nav"

  Scenario: creating an group from homepage
    Given I am signed in
    And I go to the groups page
    When I follow "Add an group"
    And I fill in "Name" with "losers" in the modal window
    And I press "Create" in the modal window
    Then I should see "losers" within "#group_nav"

  Scenario: deleting an group from followers index
    Given I am signed in
    And I have an group called "People"
    When I am on the followers page
    And I follow "People"
    And I follow "add followers to People"
    And I wait for the ajax to finish
    And I preemptively confirm the alert
    And I press "Delete" in the modal window
    Then I should be on the followers page
    And I should not see "People" within "#group_nav"

  Scenario: deleting an group from homepage
    Given I am signed in
    And I have an group called "People"
    When I am on the groups page
    And I click on "People" group edit icon
    And I wait for the ajax to finish
    And I preemptively confirm the alert
    And I press "Delete" in the modal window
    Then I should be on the groups page
    And I should not see "People" within "#group_nav"

  Scenario: Editing the group pledges of a follower from the group edit facebox
    Given I am signed in
    And I have 2 followers
    And I have an group called "Cat People"
    When I am on the followers page
    And I follow "Cat People"
    And I follow "add followers to Cat People"
    And I wait for the ajax to finish
    And I press the first ".follower_list .button"
    And I wait for the ajax to finish
    Then I should have 1 follower in "Cat People"

    When I press the first ".follower_list .button"
    And I wait for the ajax to finish
    Then I should have 0 followers in "Cat People"

  Scenario: infinite scroll on followers index
    Given I am signed in
    And I resize my window to 800x600
    And I have 30 followers
    And I am on the followers page
    Then I should see 25 followers

    When I scroll down
    Then I should see 30 followers

  Scenario: clicking on the followers link in the header with zero followers directs a user to the featured users page
    Given I am signed in
    And I have 0 followers
    And I am on the home page

    And I click on my name in the header
    When I follow "Followers"
    Then I should see "Community Spotlight" within ".span-18"

  Scenario: clicking on the followers link in the header with followers does not send a user to the featured users page
    Given I am signed in
    And I have 2 followers
    And I am on the home page

    And I click on my name in the header
    When I follow "Followers"
    Then I should not see "Featured Users" within "#section_header"

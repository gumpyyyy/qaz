@javascript
Feature: following and being followed

  Background:
    Given following users exist:
      | email             |
      | bob@bob.bob       |
      | alice@alice.alice |
    
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    And I add the person to my "Besties" group

    When I am on the home page
    And I expand the publisher
    And I fill in the following:
        | status_message_fake_text    | I am following you    |
    And I press "Share"
    Then I go to the destroy user session page

  Scenario: seeing a follower's posts on their profile page, but not in your stream
    When I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page
    Then I should see "I am following you"

    And I am on the home page
    Then I should not see "I am following you"

  Scenario: seeing public posts of someone you follow
    Given I sign in as "alice@alice.alice"
    And I am on the home page
    And I expand the publisher
    And I fill in the following:
        | status_message_fake_text    | I am ALICE    |
    And I press the first ".toggle" within "#publisher"
    And I press the first ".public" within "#publisher"
    And I press "Share"
    And I go to the destroy user session page

    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page
    Then I should see "I am ALICE"

    When I am on the home page
    Then I should see "I am ALICE"

  Scenario: seeing non-public posts of someone you follow who also follows you
    When I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page

    And I add the person to my "Besties" group
    And I wait for the ajax to finish
    And I add the person to my "Unicorns" group

    When I go to the home page

    Then I should have 1 follower in "Unicorns"
    Then I should have 1 follower in "Besties"

    When I am on the home page
    And I post "I am following you back"
    Then I go to the destroy user session page

    When I sign in as "bob@bob.bob"
    Then I should have 1 followers in "Besties"

    When I am on the home page
    Then I should see "I am following you back"

  Scenario: adding someone who follows you while creating a new group
    When I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page

    And I press the first ".toggle.button"
    And I press the first "a" within ".add_group"
    And I wait for the ajax to finish

    And I fill in "Name" with "Super People" in the modal window
    And I press "Create" in the modal window
    And I wait for the ajax to finish

    When I go to the home page
    Then I should have 1 follower in "Super People"
    Then I go to the destroy user session page

    When I sign in as "bob@bob.bob"
    Then I should have 1 follower in "Besties"

  Scenario: interacting with the profile page of someone you follow who is not following you
    When I sign in as "bob@bob.bob"
    And I am on "alice@alice.alice"'s page

    Then I should see "Besties" and "Mention"  
    Then I should not see "Message" within "#profile"

  Scenario: interacting with the profile page of someone who follows you but who you do not follow
    Given I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page

    Then I should see "Add follower"
    Then I should not see "Mention" and "Message" within "#profile"

  Scenario: interacting with the profile page of someone you follow who also follows you
    Given I sign in as "alice@alice.alice"
    And I am on "bob@bob.bob"'s page

    When I add the person to my "Besties" group
    And I wait for the ajax to finish
    And I add the person to my "Unicorns" group
    And I wait for the ajax to finish

    When I go to "bob@bob.bob"'s page
    Then I should see "All Groups" and "Mention" and "Message"

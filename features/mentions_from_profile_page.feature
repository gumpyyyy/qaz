@javascript
Feature: mentioning a follower from their profile page
    In order to enlighten humanity for the good of society
    As a rock star
    I want to mention someone more cool than the average bear

    Background:
      Given I am on the home page
      And following users exist:
        | username   |
        | bob        |
        | alice      |

      When I sign in as "bob@bob.bob"
      And a user with username "bob" is connected with "alice"
      And I have following groups:
        | PostingTo            |
        | NotPostingThingsHere |
      And I have user with username "alice" in an group called "PostingTo"
      And I have user with username "alice" in an group called "NotPostingThingsHere"

      And I am on the home page

    Scenario: mentioning while posting to all groups
      Given I am on "alice@alice.alice"'s page
      And I have turned off jQuery effects
      And I want to mention her from the profile
      And I append "I am eating a yogurt" to the publisher
      And I press "Share" in the modal window
      And I wait for the ajax to finish
      When I am on the groups page
      And I follow "PostingTo" within "#group_nav"
      And I wait for the ajax to finish
      Then I should see "I am eating a yogurt"

      When I am on the groups page
      And I follow "NotPostingThingsHere" within "#group_nav"
      And I wait for the ajax to finish
      Then I should see "I am eating a yogurt"

    Scenario: mentioning while posting to just one group
      Given I am on "alice@alice.alice"'s page
      And I have turned off jQuery effects
      And I want to mention her from the profile
      And I append "I am eating a yogurt" to the publisher
      And I press the group dropdown in the modal window
      And I toggle the group "NotPostingThingsHere" in the modal window
      And I wait for the ajax to finish
      And I press "Share" in the modal window

      When I am on the groups page
      And I select only "PostingTo" group
      Then I should see "I am eating a yogurt"

      When I am on the groups page
      And I select only "NotPostingThingsHere" group
      Then I should not see "I am eating a yogurt"

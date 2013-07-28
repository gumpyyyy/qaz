@javascript
Feature: posting from the main page
    In order to enlighten humanity for the good of society
    As a rock star
    I want to tell the world I am eating a yogurt

    Background:
      Given following users exist:
        | username   |
        | bob        |
        | alice      |
      And I sign in as "bob@bob.bob"
      And a user with username "bob" is connected with "alice"
      Given I have following groups:
        | PostingTo            |
        | NotPostingThingsHere |
      And I have user with username "alice" in an group called "PostingTo"
      And I have user with username "alice" in an group called "NotPostingThingsHere"
      And I am on the home page

    Scenario: post a text-only message to all groups
      Given I expand the publisher
      When I fill in the following:
          | status_message_fake_text    | I am eating yogurt    |
      And I press "Share"
      And I wait for the ajax to finish

      And I go to the groups page
      Then "I am eating yogurt" should be post 1

    Scenario: re-posting a text-only message
      Given I expand the publisher
      When I fill in the following:
          | status_message_fake_text    | The World needs more Cats.    |
      And I press "Share"
      And I wait for the ajax to finish

      Given I expand the publisher
      When I fill in the following:
          | status_message_fake_text    | The World needs more Cats.    |
      And I press "Share"
      And I wait for the ajax to finish

      And I go to the groups page
      Then "The World needs more Cats." should be post 1
      Then "The World needs more Cats." should be post 2

    Scenario: posting a message appends it to the top of the stream
      When I click the publisher and post "sup dog"
      And I wait for 1 second
      And I click the publisher and post "hello there"
      Then I should see "hello there" as the first post in my stream

    Scenario: post a text-only message to just one group
      When I select only "PostingTo" group
      And I expand the publisher
      And I fill in the following:
          | status_message_fake_text    | I am eating a yogurt    |
      
      And I press "Share"
      And I wait for the ajax to finish

      When I am on the groups page
      And I select only "PostingTo" group
      Then I should see "I am eating a yogurt"

      When I am on the groups page
      And I select only "NotPostingThingsHere" group
      Then I should not see "I am eating a yogurt"

    Scenario: post a photo with text
      Given I expand the publisher
      When I attach the file "spec/fixtures/button.png" to hidden element "file" within "#file-upload"
      When I fill in the following:
          | status_message_fake_text    | Look at this dog    |
      And I press "Share"
      And I wait for the ajax to finish
      And I go to the groups page
      Then I should see a "img" within ".stream_element div.photo_attachments"
      And I should see "Look at this dog" within ".stream_element"
      When I log out
      And I sign in as "alice@alice.alice"
      And I go to "bob@bob.bob"'s page
      Then I should see a "img" within ".stream_element div.photo_attachments"
      And I should see "Look at this dog" within ".stream_element"

    Scenario: post a photo without text
      Given I expand the publisher
      When I attach the file "spec/fixtures/button.png" to hidden element "file" within "#file-upload"
      And I wait for the ajax to finish
      Then I should see an uploaded image within the photo drop zone
      When I press "Share"
      And I wait for the ajax to finish
      And I go to the groups page
      Then I should see a "img" within ".stream_element div.photo_attachments"
      When I log out
      And I sign in as "alice@alice.alice"
      And I go to "bob@bob.bob"'s page
      Then I should see a "img" within ".stream_element div.photo_attachments"

    Scenario: back out of posting a photo-only post
      Given I expand the publisher
      And I have turned off jQuery effects
      When I attach the file "spec/fixtures/bad_urls.txt" to "file" within "#file-upload"
      And I preemptively confirm the alert
      Then I should not see an uploaded image within the photo drop zone
      When I attach the file "spec/fixtures/button.png" to hidden element "file" within "#file-upload"
      And I wait for the ajax to finish
      And I click to delete the first uploaded photo
      And I wait for the ajax to finish
      Then I should not see an uploaded image within the photo drop zone

    Scenario: back out of uploading a picture to a post with text
      Given I expand the publisher
      And I have turned off jQuery effects
      When I fill in the following:
          | status_message_fake_text    | I am eating a yogurt    |
      And I attach the file "spec/fixtures/button.png" to hidden element "file" within "#file-upload"
      And I wait for the ajax to finish
      And I click to delete the first uploaded photo
      And I wait for the ajax to finish
      Then I should not see an uploaded image within the photo drop zone
      And the publisher should be expanded

    Scenario: back out of uploading a picture when another has been attached
      Given I expand the publisher
      And I have turned off jQuery effects
      When I fill in the following:
          | status_message_fake_text    | I am eating a yogurt    |
      And I attach the file "spec/fixtures/button.png" to hidden element "file" within "#file-upload"
      And I attach the file "spec/fixtures/button.png" to hidden element "file" within "#file-upload"
      And I wait for the ajax to finish
      And I click to delete the first uploaded photo
      And I wait for the ajax to finish
      Then I should see an uploaded image within the photo drop zone
      And the publisher should be expanded

    @wip
    Scenario: hide a follower's post
      Given I expand the publisher
      When I fill in the following:
          | status_message_fake_text    | Here is a post for you to hide    |
      And I press "Share"
      And I wait for the ajax to finish

      And I log out
      And I sign in as "alice@alice.alice"
      And I am on "bob@bob.bob"'s page

      And I hover over the ".stream_element"
      And I preemptively confirm the alert
      And I click to delete the first post
      And I wait for the ajax to finish
      And I go to "bob@bob.bob"'s page
      And I wait for the ajax to finish
      Then I should not see "Here is a post for you to hide"
      When I am on the groups page
      And I wait for the ajax to finish
      Then I should not see "Here is a post for you to hide"

    Scenario: delete one of my posts
      Given I expand the publisher
      When I fill in the following:
          | status_message_fake_text    | I am eating a yogurt    |
      And I press "Share"
      And I wait for the ajax to finish
      And I go to the groups page
      And I hover over the ".stream_element"
      And I preemptively confirm the alert
      And I click to delete the first post
      And I wait for the ajax to finish
      And I go to the groups page
      Then I should not see "I am eating a yogurt"

    Scenario: change post target groups with the group-dropdown before posting
      When I expand the publisher
      And I press the group dropdown
      And I toggle the group "PostingTo"
      And I append "I am eating a yogurt" to the publisher
      And I press "Share"
      And I wait for the ajax to finish

      And I am on the groups page
      And I select only "PostingTo" group
      Then I should see "I am eating a yogurt"
      When I am on the groups page
      And I select only "NotPostingThingsHere" group
      Then I should not see "I am eating a yogurt"

    Scenario: post 2 in a row using the groups-dropdown
      When I expand the publisher
      And I press the group dropdown
      And I toggle the group "PostingTo"
      And I append "I am eating a yogurt" to the publisher
      And I press "Share"
      And I wait for the ajax to finish

      And I expand the publisher
      And I press the group dropdown
      And I toggle the group "Besties"
      And I append "And cornflakes also" to the publisher
      And I press "Share"
      And I wait for the ajax to finish

      And I am on the groups page
      And I select only "PostingTo" group
      Then I should see "I am eating a yogurt" and "And cornflakes also"
      When I am on the groups page
      And I select only "Besties" group
      Then I should not see "I am eating a yogurt"
      Then I should see "And cornflakes also"
      When I am on the groups page
      And I select only "NotPostingThingsHere" group
      Then I should not see "I am eating a yogurt" and "And cornflakes also"

    # (NOTE) make this a jasmine spec
    Scenario: reject deletion one of my posts
      When I expand the publisher
      When I fill in the following:
          | status_message_fake_text    | I am eating a yogurt    |
      And I press "Share"
      And I wait for the ajax to finish

      And I hover over the ".stream_element"
      And I preemptively reject the alert
      And I click to delete the first post
      Then I should see "I am eating a yogurt"

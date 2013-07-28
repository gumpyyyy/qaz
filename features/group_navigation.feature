@javascript
Feature: Group navigation on the left menu
    In order to filter posts visibility and post targeting
    As a lygneo user
    I want to use the group navigation menu

    Background:
      Given a user with username "bob"
      And I sign in as "bob@bob.bob"
      And I have an group called "Others"

    Scenario: All groups are selected by default
      When I go to the groups page
      Then I should see "Besties" group selected
      Then I should see "Unicorns" group selected
      Then I should see "Others" group selected

    Scenario: Groups selection is remembered through site navigation
      When I go to the groups page
      And I select only "Besties" group
      And I go to the followers page
      And I go to the groups page
      Then I should see "Besties" group selected
      Then I should see "Unicorns" group unselected
      Then I should see "Others" group unselected

    Scenario: Groups selection can include one or more groups
      When I go to the groups page
      And I select only "Besties" group
      And I select "Unicorns" group as well
      Then I should see "Besties" group selected
      Then I should see "Unicorns" group selected
      Then I should see "Others" group unselected

    Scenario: Deselect all groups
      When I go to the groups page
      And I follow "Deselect all"
      Then I should see "Besties" group unselected
      Then I should see "Unicorns" group unselected
      Then I should see "Others" group unselected

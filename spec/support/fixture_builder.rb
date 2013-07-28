require File.join(File.dirname(__FILE__), "user_methods.rb")

FixtureBuilder.configure do |fbuilder|

  # rebuild fixtures automatically when these files change:
  fbuilder.files_to_check += Dir["app/models/*.rb", "lib/**/*.rb",  "spec/factories/*.rb", "spec/support/fixture_builder.rb"]

  # now declare objects
  fbuilder.factory do
    # Users
    alice = FactoryGirl.create(:user_with_group, :username => "alice")
    alices_group = alice.groups.where(:name => "generic").first

    eve   = FactoryGirl.create(:user_with_group, :username => "eve")
    eves_group = eve.groups.where(:name => "generic").first

    bob   = FactoryGirl.create(:user_with_group, :username => "bob")
    bobs_group = bob.groups.where(:name => "generic").first
    FactoryGirl.create(:group, :name => "empty", :user => bob)

    connect_users(bob, bobs_group, alice, alices_group)
    connect_users(bob, bobs_group, eve, eves_group)

    # Set up friends - 2 local, 1 remote
    local_luke = FactoryGirl.create(:user_with_group, :username => "luke")
    lukes_group = local_luke.groups.where(:name => "generic").first

    local_leia = FactoryGirl.create(:user_with_group, :username => "leia")
    leias_group = local_leia.groups.where(:name => "generic").first

    remote_raphael = FactoryGirl.create(:person, :lygneo_handle => "raphael@remote.net")

    connect_users_with_groups(local_luke, local_leia)

    local_leia.followers.create(:person => remote_raphael, :groups => [leias_group])
    local_luke.followers.create(:person => remote_raphael, :groups => [lukes_group])
   end
end
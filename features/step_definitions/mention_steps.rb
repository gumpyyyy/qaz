And /^Alice has a post mentioning Bob$/ do
  alice = User.find_by_email 'alice@alice.alice'
  bob = User.find_by_email 'bob@bob.bob'
  group = alice.groups.where(:name => "Besties").first
  alice.post(:status_message, :text => "@{Bob Jones; #{bob.person.lygneo_handle}}", :to => group)
end

And /^I mention Alice in the publisher$/ do
  alice = User.find_by_email 'alice@alice.alice'
  fill_in 'status_message_fake_text', :with => "@{Alice Smith ; #{alice.person.lygneo_handle}}"
end

And /^I click on the first user in the mentions dropdown list$/ do
  find('.mentions-autocomplete-list li:first').click
end

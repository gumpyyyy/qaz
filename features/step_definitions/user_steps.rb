Given /^a user with username "([^\"]*)" and password "([^\"]*)"$/ do |username, password|
  @me ||= FactoryGirl.create(:user, :username => username, :password => password,
                  :password_confirmation => password, :getting_started => false)
  @me.groups.create(:name => "Besties")
  @me.groups.create(:name => "Unicorns")
  @me.reload
end

Given /^a user with email "([^\"]*)"$/ do |email|
  create_user(:email => email)
end

Given /^a user with username "([^\"]*)"$/ do |username|
  create_user(:email => username + "@" + username + '.' + username, :username => username)
end

Given /^a user named "([^\"]*)" with email "([^\"]*)"$/ do |name, email|
  first, last = name.split
  user = create_user(:email => email, :username => "#{first}_#{last}")
  user.profile.update_attributes!(:first_name => first, :last_name => last) if first
end

Given /^a nsfw user with email "([^\"]*)"$/ do |email|
  user = create_user(:email => email)
  user.profile.update_attributes(:nsfw => true)
end


Given /^(?:|[tT]hat )?following user[s]?(?: exist[s]?)?:$/ do |table|
  table.hashes.each do |hash|
    if hash.has_key? "username" and hash.has_key? "email"
      step %{a user named "#{hash['username']}" with email "#{hash['email']}"}
    elsif hash.has_key? "username"
      step %{a user with username "#{hash['username']}"} 
    elsif hash.has_key? "email"
      step %{a user with email "#{hash['email']}"}
    end
  end
end


Given /^I have been invited by an admin$/ do
  admin = FactoryGirl.create(:user)
  admin.invitation_code
  i = EmailInviter.new("new_invitee@example.com", admin)
  i.send!
end

Given /^I have been invited by bob$/ do
  @inviter = FactoryGirl.create(:user, :email => 'bob@bob.bob')
  @inviter_invite_count = @inviter.invitation_code.count
  i = EmailInviter.new("new_invitee@example.com", @inviter)
  i.send!
end

When /^I should see one less invite$/ do
  step "I should see \"#{@inviter_invite_count -1} invites left\""
end

When /^I click on my name$/ do
  click_link("#{@me.first_name} #{@me.last_name}")
end

Given /^I have an group called "([^\"]*)"$/ do |group_name|
  @me.groups.create!(:name => group_name)
  @me.reload
end

Given /^I have following group[s]?:$/ do |fields|
  fields.raw.each do |field|
    step %{I have an group called "#{field[0]}"}
  end
end

When /^I have user with username "([^"]*)" in an group called "([^"]*)"$/ do |username, group|
  user = User.find_by_username(username)
  follower = @me.reload.follower_for(user.person)
  follower.groups << @me.groups.find_by_name(group)
end

Given /^a user with email "([^"]*)" is connected with "([^"]*)"$/ do |arg1, arg2|
  user1 = User.where(:email => arg1).first
  user2 = User.where(:email => arg2).first
  connect_users(user1, user1.groups.where(:name => "Besties").first, user2, user2.groups.where(:name => "Besties").first)
end

Given /^a user with username "([^"]*)" is connected with "([^"]*)"$/ do |arg1, arg2|
  user1 = User.where(:username => arg1).first
  user2 = User.where(:username => arg2).first
  connect_users(user1, user1.groups.where(:name => "Besties").first, user2, user2.groups.where(:name => "Besties").first)
end

Given /^there is a user "([^\"]*)" who's tagged "([^\"]*)"$/ do |full_name, tag|
  username = full_name.gsub(/\W/, "").underscore
  step "a user named \"#{full_name}\" with email \"#{username}@example.com\""
  user = User.find_by_username(username)
  user.profile.tag_string = tag
  user.profile.build_tags
  user.profile.save!
end

Given /^many posts from alice for bob$/ do
  alice = FactoryGirl.create(:user_with_group, :username => 'alice', :email => 'alice@alice.alice', :password => 'password', :getting_started => false)
  bob = FactoryGirl.create(:user_with_group, :username => 'bob', :email => 'bob@bob.bob', :password => 'password', :getting_started => false)
  connect_users_with_groups(alice, bob)
  time_fulcrum = Time.now - 40000
  time_interval = 1000
  (1..30).each do |n|
    post = alice.post :status_message, :text => "#{alice.username} - #{n} - #seeded", :to => alice.groups.where(:name => "generic").first.id
    post.created_at = time_fulcrum - time_interval
    post.updated_at = time_fulcrum + time_interval
    post.save
    time_interval += 1000
  end
end

Then /^I should have (\d) followers? in "([^"]*)"$/ do |n_followers, group_name|
  @me.groups.where(:name => group_name).first.followers.count.should == n_followers.to_i
end

When /^I (?:add|remove) the person (?:to|from) my "([^\"]*)" group$/ do |group_name|
    groups_dropdown = find(".group_pledge .toggle.button:first")
    groups_dropdown.click
    find(".dropdown.active .dropdown_list li:contains('#{group_name}')").click
    groups_dropdown.click
end

When /^I post a status with the text "([^\"]*)"$/ do |text|
  @me.post(:status_message, :text => text, :public => true, :to => 'all')
end

And /^I follow the "([^\"]*)" link from the last sent email$/ do |link_text|
  email_text = Devise.mailer.deliveries.first.body.to_s
  email_text = Devise.mailer.deliveries.first.html_part.body.raw_source if email_text.blank?
  doc = Nokogiri("<div>" + email_text + "</div>")

  links = doc.css('a')
  link = links.detect{ |link| link.text == link_text }
  link = links.detect{ |link| link.attributes["href"].value.include?(link_text)} unless link
  path = link.attributes["href"].value
  visit URI::parse(path).request_uri
end

Then /^I should have (\d+) Devise email delivery$/ do |n|
  Devise.mailer.deliveries.length.should == n.to_i
end

Then /^I should have (\d+) email delivery$/ do |n|
  ActionMailer::Base.deliveries.length.should == n.to_i
end

Then /^I should not see "([^\"]*)" in the last sent email$/ do |text|
  email_text = Devise.mailer.deliveries.first.body.to_s
  email_text = Devise.mailer.deliveries.first.html_part.body.raw_source if email_text.blank?
  email_text.should_not match(text)
end

When /^"([^\"]+)" has posted a status message with a photo$/ do |email|
  user = User.find_for_database_authentication(:username => email)
  post = FactoryGirl.create(:status_message_with_photo, :text => "Look at this dog", :author => user.person)
  [post, post.photos.first].each do |p|
    user.add_to_streams(p, user.groups)
    user.dispatch_post(p)
  end
end

Then /^my "([^\"]*)" should be "([^\"]*)"$/ do |field, value|
  @me.reload.send(field).should == value
end

Given /^I have (\d+) followers$/ do |n|
  count = n.to_i - @me.followers.count

  people = []
  followers = []
  group_pledges = []

  count.times do
    person = FactoryGirl.create(:person)
    people << person
  end

  people.each do |person|
    followers << Follower.new(:person_id => person.id, :user_id => @me.id, :sharing => true, :receiving => true)
  end
  Follower.import(followers)
  followers = @me.followers.limit(n.to_i)

  group_id = @me.groups.length == 1 ? @me.groups.first.id : @me.groups.where(:name => "Besties").first.id
  followers.each do |follower|
    group_pledges << GroupPledge.new(:follower_id => follower.id, :group_id => group_id)
  end
  GroupPledge.import(group_pledges)
end

When /^I view "([^\"]*)"'s first post$/ do |email|
  user = User.find_by_email(email)
  post = user.posts.first
  visit post_path(post)
end

Given /^I visit alice's invitation code url$/ do
  @alice ||= FactoryGirl.create(:user, :username => 'alice', :getting_started => false)
  invite_code  = InvitationCode.find_or_create_by_user_id(@alice.id)
  visit invite_code_path(invite_code)
end

When /^I fill in the new user form$/ do
  step 'I fill in "user_username" with "ohai"'
  step 'I fill in "user_email" with "ohai@example.com"'
  step 'I fill in "user_password" with "secret"'
  step 'I fill in "user_password_confirmation" with "secret"'
end

And /^I should be able to friend Alice$/ do
  alice = User.find_by_username 'alice'
  step 'I should see "Add follower"'
  step "I should see \"#{alice.name}\""
end

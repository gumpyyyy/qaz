#   Copyright (c) 2010-2011, Lygneo In  This file is
#   licensed under the Affero General Public License version 3 or late  See
#   the COPYRIGHT file.

#For Guidance
#http://github.com/thoughtbot/factory_girl
# http://railscasts.com/episodes/158-factories-not-fixtures

def r_str
  SecureRandom.hex(3)
end

FactoryGirl.define do
  factory :profile do
    sequence(:first_name) { |n| "Robert#{n}#{r_str}" }
    sequence(:last_name)  { |n| "Grimm#{n}#{r_str}" }
    bio "I am a cat lover and I love to run"
    gender "robot"
    location "Earth"
    birthday Date.today
  end

  factory :profile_with_image_url, :parent => :profile do
    image_url "http://example.com/image.jpg"
    image_url_medium "http://example.com/image_mid.jpg"
    image_url_small "http://example.com/image_small.jpg"
  end

  factory :person do
    sequence(:lygneo_handle) { |n| "bob-person-#{n}#{r_str}@example.net" }
    url AppConfig.pod_uri.to_s
    serialized_public_key OpenSSL::PKey::RSA.generate(1024).public_key.export
    after(:build) do |person|
      person.profile = FactoryGirl.build(:profile, :person => person) unless person.profile.first_name.present?
    end
    after(:create) do |person|
      person.profile.save
    end
  end

  factory :account_deletion do
    association :person
    after(:build) do |delete|
      delete.lygneo_handle = delete.person.lygneo_handle
    end
  end

  factory :searchable_person, :parent => :person do
    after(:build) do |person|
      person.profile = FactoryGirl.build(:profile, :person => person, :searchable => true)
    end
  end

  factory :like do
    association :author, :factory => :person
    association :target, :factory => :status_message
  end

  factory :user do
    getting_started false
    sequence(:username) { |n| "bob#{n}#{r_str}" }
    sequence(:email) { |n| "bob#{n}#{r_str}@pivotallabs.com" }
    password "bluepin7"
    password_confirmation { |u| u.password }
    serialized_private_key  OpenSSL::PKey::RSA.generate(1024).export
    after(:build) do |u|
      u.person = FactoryGirl.build(:person, :profile => FactoryGirl.build(:profile),
                                  :owner_id => u.id,
                                  :serialized_public_key => u.encryption_key.public_key.export,
                                  :lygneo_handle => "#{u.username}#{User.lygneo_id_host}")
    end
    after(:create) do |u|
      u.person.save
      u.person.profile.save
    end
  end

  factory :user_with_group, :parent => :user do
    after(:create) { |u|  FactoryGirl.create(:group, :user => u) }
  end

  factory :group do
    name "generic"
    user
  end

  factory(:status_message) do
    sequence(:text) { |n| "jimmy's #{n} whales" }
    association :author, :factory => :person
    after(:build) do |sm|
      sm.lygneo_handle = sm.author.lygneo_handle
    end
  end

  factory(:status_message_with_photo, :parent => :status_message) do
    sequence(:text) { |n| "There are #{n} ninjas in this photo." }
    after(:build) do |sm|
      FactoryGirl.create(:photo, :author => sm.author, :status_message => sm, :pending => false, :public => sm.public)
    end
  end

  factory(:status_message_in_group, parent: :status_message) do
    self.public false
    after :build do |sm|
      sm.author = FactoryGirl.create(:user_with_group).person
      sm.groups << sm.author.owner.groups.first
    end
  end

  factory(:photo) do
    sequence(:random_string) {|n| SecureRandom.hex(10) }
    association :author, :factory => :person
    after(:build) do |p|
      p.unprocessed_image.store! File.open(File.join(File.dirname(__FILE__), 'fixtures', 'button.png'))
      p.update_remote_path
    end
  end

  factory(:remote_photo, :parent => :photo) do
    remote_photo_path 'https://photo.com/images/'
    remote_photo_name 'kittehs.jpg'
    association :author,:factory => :person
    processed_image nil
    unprocessed_image nil
  end

  factory :reshare do
    association(:root, :public => true, :factory => :status_message)
    association(:author, :factory => :person)
  end

  factory :invitation do
    service "email"
    identifier "bob.smith@smith.com"
    association :sender, :factory => :user_with_group
    after(:build) do |i|
      i.group = i.sender.groups.first
    end
  end

  factory :invitation_code do
    sequence(:token){|n| "sdfsdsf#{n}"}
    association :user
    count 0
  end

  factory :service do |service|
    nickname "sirrobertking"
    type "Services::Twitter"

    sequence(:uid)           { |token| "00000#{token}" }
    sequence(:access_token)  { |token| "12345#{token}" }
    sequence(:access_secret) { |token| "98765#{token}" }
  end

  factory :service_user do
    sequence(:uid) { |id| "a#{id}"}
    sequence(:name) { |num| "Rob Fergus the #{num.ordinalize}" }
    association :service
    photo_url "/assets/user/adams.jpg"
  end

  factory(:comment) do
    sequence(:text) {|n| "#{n} cats"}
    association(:author, :factory => :person)
    association(:post, :factory => :status_message)
  end

  factory(:notification) do
    association :recipient, :factory => :user
    association :target, :factory => :comment
    type 'Notifications::AlsoCommented'

    after(:build) do |note|
      note.actors << FactoryGirl.build(:person)
    end
  end

  factory(:activity_streams_photo, :class => ActivityStreams::Photo) do
    association(:author, :factory => :person)
    image_url "#{AppConfig.environments.url}/assets/asterisk.png"
    image_height 154
    image_width 154
    object_url "http://example.com/awesome_things.gif"
    objectId "http://example.com/awesome_things.gif"
    actor_url "http://notcubbes/cubber"
    provider_display_name "not cubbies"
    public true
  end

  factory(:tag, :class => ActsAsTaggableOn::Tag) do
    name "partytimeexcellent"
  end

  factory(:o_embed_cache) do
    url "http://youtube.com/kittens"
    data {{'data' => 'foo'}}
  end

  factory(:tag_following) do
    association(:tag, :factory => :tag)
    association(:user, :factory => :user)
  end

  factory(:follower) do
    association(:person, :factory => :person)
    association(:user, :factory => :user)
  end

  factory(:mention) do
    association(:person, :factory => :person)
    association(:post, :factory => :status_message)
  end

  #templates
  factory(:status_with_photo_backdrop, :parent => :status_message_with_photo)

  factory(:photo_backdrop, :parent => :status_message_with_photo) do
    text ""
  end

  factory(:note, :parent => :status_message) do
    text SecureRandom.hex(1000)
  end

  factory(:status, :parent => :status_message)
end

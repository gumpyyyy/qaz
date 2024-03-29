When /^I visit the mobile groups page$/ do
  visit('/groups.mobile')
end

When /^I visit the mobile home page$/ do
  visit('/users/sign_in.mobile')
end

Given /^I publisher mobile page$/ do
  visit('/status_messages/new.mobile')
end

When /^I visit the mobile stream page$/ do
  visit('/stream.mobile')
end

When /^I toggle the mobile view$/ do
  visit('/mobile/toggle')
end

When /^I visit the mobile getting started page$/ do
  visit('/getting_started.mobile')
end

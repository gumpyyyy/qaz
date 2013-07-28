When /^I click on "([^"]*)" group edit icon$/ do |group_name|
  step %{I hover over the "ul.sub_nav > li:contains('#{group_name}')"}
  within("#group_nav") do
    find('a > .edit').click
  end
end

When /^I select only "([^"]*)" group$/ do |group_name|
  within('#group_nav') do
    click_link 'Groups'
    click_link 'Select all' if has_link? 'Select all'
  end

  step %{I wait for the ajax to finish}

  within('#group_nav') do
    click_link 'Deselect all' if has_link? 'Deselect all'
  end

  step %{I wait for the ajax to finish}

  within('#group_nav') do
    click_link group_name
  end

  step %{I wait for the ajax to finish}
end

When /^I select "([^"]*)" group as well$/ do |group_name|
  within('#group_nav') do
    click_link group_name
  end

  step %{I wait for the ajax to finish}
end

When /^I should see "([^"]*)" group selected$/ do |group_name|
  group = @me.groups.where(:name => group_name).first
  within("#group_nav") do
    page.has_css?("li.active[data-group_id='#{group.id}']").should be_true
    page.has_no_css?("li.active[data-group_id='#{group.id}'] .invisible").should be_true
  end
end

When /^I should see "([^"]*)" group unselected$/ do |group_name|
  group = @me.groups.where(:name => group_name).first
  within("#group_nav") do
    page.has_css?("li[data-group_id='#{group.id}']:not(.active) .invisible").should be_true
  end
end

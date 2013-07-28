#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module GroupGlobalHelper
  def group_pledge_dropdown(follower, person, hang, group=nil)
    group_pledge_ids = {}

    selected_groups = all_groups.select{|group| follower.in_group?(group)}
    selected_groups.each do |a|
      record = a.group_pledges.find { |am| am.follower_id == follower.id }
      group_pledge_ids[a.id] = record.id
    end

    render "shared/group_dropdown",
      :selected_groups => selected_groups,
      :group_pledge_ids => group_pledge_ids,
      :person => person,
      :hang => hang,
      :dropdown_class => "group_pledge"
  end

  def group_dropdown_list_item(group, am_id=nil)
    klass = am_id.present? ? "selected" : ""

    str = <<LISTITEM
<li data-group_id="#{group.id}" data-pledge_id="#{am_id}" class="#{klass} group_selector">
  #{group.name}
</li>
LISTITEM
    str.html_safe
  end

  def dropdown_may_create_new_group
    @group == :profile || @group == :tag || @group == :search || @group == :notification || params[:action] == "getting_started"
  end

  def group_options_for_select(groups)
    options = {}
    groups.each do |group|
      options[group.to_s] = group.id
    end
    options
  end
end

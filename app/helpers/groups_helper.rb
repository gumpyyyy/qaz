#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module GroupsHelper
  def add_to_group_button(group_id, person_id)
    link_to content_tag(:div, nil, :class => 'icons-monotone_plus_add_round'),
      { :controller => 'group_pledges',
        :action => 'create',
        :format => :json,
        :group_id => group_id,
        :person_id => person_id
      },
      :method => 'post',
      :class => 'add button',
      'data-group_id' => group_id,
      'data-person_id' => person_id
  end

  def remove_from_group_button(pledge_id, group_id, person_id)
    link_to content_tag(:div, nil, :class => 'icons-monotone_check_yes'),
      { :controller => "group_pledges",
        :action => 'destroy',
        :id => pledge_id
      },
      :method => 'delete',
      :class => 'added button',
      'data-pledge_id' => pledge_id,
      'data-group_id' => group_id,
      'data-person_id' => person_id
  end

  def group_pledge_button(group, follower, person)
    return if person && person.closed_account?

    pledge = follower.group_pledges.where(:group_id => group.id).first
    if follower.nil? || pledge.nil?
      add_to_group_button(group.id, person.id)
    else
      remove_from_group_button(pledge.id, group.id, person.id)
    end
  end
end

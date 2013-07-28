module FollowersHelper
  def follower_group_dropdown(follower)
    pledge = follower.group_pledges.where(:group_id => @group.id).first unless @group.nil?

    if pledge
      link_to(content_tag(:div, nil, :class => 'icons-monotone_close_exit_delete'),
        { :controller => "group_pledges",
          :action => 'destroy',
          :id => pledge.id
        },
        :title => t('followers.index.remove_person_from_group', :person_name => follower.person_first_name, :group_name => @group.name),
        :class => 'follower_remove-from-group',
        :method => 'delete',
        'data-pledge_id' => pledge.id
      )

    else
      render :partial => 'people/relationship_action',
              :locals => { :person => follower.person,
                           :follower => follower,
                           :current_user => current_user }
    end
  end

  def start_a_conversation_link(group, followers_size)
    suggested_limit = 16
    conv_opts = { :class => "button conversation_button", :rel => "facebox"}
    conv_opts[:title] = t('.many_people_are_you_sure', :suggested_limit => suggested_limit) if followers_size > suggested_limit
    link_to t('.start_a_conversation'), new_conversation_path(:group_id => group.id, :name => group.name), conv_opts
  end
end

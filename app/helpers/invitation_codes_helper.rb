module InvitationCodesHelper
  def invite_hidden_tag(invite)
    if invite.present?
      hidden_field_tag 'invite[token]', invite.token
    end
  end

  def invite_link(invite_code)
    text_field_tag :invite_code, invite_code_url(invite_code), :readonly => true
  end

  def invited_by_message
    inviter = current_user.invited_by
    if inviter.present?
      follower = current_user.follower_for(inviter.person) || Follower.new 
      render :partial => 'people/add_follower', :locals => {:inviter => inviter.person, :follower => follower}
    end
  end
end

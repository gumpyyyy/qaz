#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe 'disconnecting a follower' do
  it 'removes the group pledge' do
    @user = alice
    @user2 = bob

    lambda{
      @user.disconnect(@user.follower_for(@user2.person))
    }.should change(GroupPledge, :count).by(-1)
  end
end

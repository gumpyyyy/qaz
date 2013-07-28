#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
require 'spec_helper'

describe GroupPledge do

  describe '#before_destroy' do
    before do
      @group = alice.groups.create(:name => "two")
      @follower = alice.follower_for(bob.person)

      @am = alice.groups.where(:name => "generic").first.group_pledges.first
      @am.stub!(:user).and_return(alice)
    end

    it 'calls disconnect if its the last group for the follower' do
      alice.should_receive(:disconnect).with(@follower)

      @am.destroy
    end

    it 'does not call disconnect if its not the last group for the follower' do
      alice.should_not_receive(:disconnect)

      alice.add_follower_to_group(@follower, @group)
      @am.destroy     
    end
  end

end

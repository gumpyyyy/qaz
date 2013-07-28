#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe MobileHelper do
  
  describe "#group_select_options" do
    it "adds an all option to the list of groups" do
      # options_from_collection_for_select(@groups, "id", "name", @group.id)
      
      n = FactoryGirl.create(:group)
      
      options = group_select_options([n], n).split('\n')
      options.first.should =~ /All/
    end
  end
end
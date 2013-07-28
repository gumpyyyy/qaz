#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe FollowersController do
  describe '#index' do
    before do
      sign_in :user, bob
    end

    it "generates a jasmine fixture", :fixture => true do
      get :index
      save_fixture(html_for("body"), "groups_manage")
    end
  end
end

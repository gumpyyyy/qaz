#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Pubsubhubbub do
  describe '#publish' do
    it 'posts the feed to the given hub' do
      hub = "http://hubzord.com/"
      feed = 'http://rss.com/dom.atom'
      body = {'hub.url' => feed, 'hub.mode' => 'publish'}

      stub_request(:post, "http://hubzord.com/").to_return(:status => [202, 'you are awesome'])
      Pubsubhubbub.new(hub).publish(feed).should be_success
    end
  end
end

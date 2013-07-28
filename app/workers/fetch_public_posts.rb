#   Copyright (c) 2010-2012, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class FetchPublicPosts < Base
    sidekiq_options queue: :http_service

    def perform(lygneo_id)
      Lygneo::Fetcher::Public.new.fetch!(lygneo_id)
    end
  end
end

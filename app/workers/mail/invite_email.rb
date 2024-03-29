#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  module Mail
    class InviteEmail < Base
      sidekiq_options queue: :mail

      def perform(emails, inviter_id, options={})
        EmailInviter.new(emails, User.find(inviter_id), options).send!
      end
    end
  end
end

#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module PublisherHelper
  def remote?
    params[:controller] != "tags"
  end

  def all_groups_selected?(selected_groups)
    @all_groups_selected ||= all_groups.size == selected_groups.size
  end
end

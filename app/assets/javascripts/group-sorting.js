/*   Copyright (c) 2010-2011, Lygneo Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

$(document).ready(function() {
  $('#group_nav.left_nav .all_groups .sub_nav').sortable({
    items: "li[data-group_id]",
    update: function(event, ui) {
      var order = $(this).sortable("toArray", {attribute: "data-group_id"}),
          obj = { 'reorder_groups': order, '_method': 'put' };
      $.ajax('/user', { type: 'post', dataType: 'script', data: obj });
    },
    revert: true,
    helper: 'clone'
  });
});


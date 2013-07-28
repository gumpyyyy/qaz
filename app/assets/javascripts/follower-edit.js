//   Copyright (c) 2010-2011, Lygneo Inc.  This file is
//   licensed under the Affero General Public License version 3 or later.  See
//   the COPYRIGHT file.

var FollowerEdit = {
  inviteFriend: function(li, evt) {
    $.post('/services/inviter/facebook.json', {
      "group_id" : li.data("group_id"),
      "uid" : li.parent().data("service_uid")
    }, function(data){
      FollowerEdit.processSuccess(li, evt, data);
    });
  }
};

/*
  TODO remove me
  FollowerEdit.toggleCheckbox(li);
  Lygneo.page.publish("groupDropdown/updated", [li.parent().data("person_id"), li.parents(".dropdown").parent(".right").html()]);
*/

/**
 * TEMPORARY SOLUTION
 * TODO remove me, when the followers section is done with Backbone.js ...
 * (this is about as much covered by tests as the old code ... not at all)
 *
 * see also 'group-edit-pane.js'
 */

app.tmp || (app.tmp = {});

// on the followers page, viewing the list of people in a single group
app.tmp.FollowerGroups = function() {
  $('#people_stream').on('click', '.follower_remove-from-group', _.bind(this.removeFromGroup, this));
};
_.extend(app.tmp.FollowerGroups.prototype, {
  removeFromGroup: function(evt) {
    evt.stopImmediatePropagation();
    evt.preventDefault();

    var el = $(evt.currentTarget);
    var id = el.data('pledge_id');

    var group_pledge = new app.models.GroupPledge({'id':id});
    group_pledge.on('sync', this._successDestroyCb, this);
    group_pledge.on('error', function(group_pledge) {
      this._displayError('group_dropdown.error_remove', group_pledge.get('id'));
    }, this);

    group_pledge.destroy();

    return false;
  },

  _successDestroyCb: function(group_pledge) {
    var pledge_id = group_pledge.get('id');

    $('.stream_element').has('[data-pledge_id="'+pledge_id+'"]')
      .fadeOut(300, function() { $(this).remove() });
  },

  _displayError: function(msg_id, pledge_id) {
    var name = $('.stream_element')
      .has('[data-pledge_id="'+pledge_id+'"]')
      .find('div.bd > a')
      .text();
    var msg = Lygneo.I18n.t(msg_id, { 'name': name });
    Lygneo.page.flashMessages.render({ 'success':false, 'notice':msg });
  }
});


$(function() {
  var follower_groups = new app.tmp.FollowerGroups();
});

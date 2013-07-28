/*   Copyright (c) 2010-2011, Lygneo Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

function toggleGroupTitle(){
  $("#group_name_title").toggleClass('hidden');
  $("#group_name_edit").toggleClass('hidden');
}

function updateGroupName(new_name) {
  $('#group_name_title .name').html(new_name);
  $('input#group_name').val(new_name);
}
function updatePageGroupName( an_id, new_name) {
  $('ul#group_nav [data-guid="'+an_id+'"]').html(new_name);
}

$(document).ready(function() {
  $('#rename_group_link').live('click', function(){
    toggleGroupTitle();
  });

  $('form.edit_group').live('ajax:success', function(evt, data, status, xhr) {
    updateGroupName(data['name']);
    updatePageGroupName( data['id'], data['name'] );
    toggleGroupTitle();
  });
});


/**
 * TEMPORARY SOLUTION
 * TODO remove me, when the followers section is done with Backbone.js ...
 * (this is about as much covered by tests as the old code ... not at all)
 *
 * see also 'follower-edit.js'
 */

app.tmp || (app.tmp = {});

// on the followers page, viewing the facebox for single group
app.tmp.FollowerGroupsBox = function() {
  $('body').on('click', '#group_edit_pane a.add.button', _.bind(this.addToGroup, this));
  $('body').on('click', '#group_edit_pane a.added.button', _.bind(this.removeFromGroup, this));
};
_.extend(app.tmp.FollowerGroupsBox.prototype, {
  addToGroup: function(evt) {
    var el = $(evt.currentTarget);
    var group_pledge = new app.models.GroupPledge({
      'person_id': el.data('person_id'),
      'group_id': el.data('group_id')
    });

    group_pledge.on('sync', this._successSaveCb, this);
    group_pledge.on('error', function() {
      this._displayError('group_dropdown.error', el);
    }, this);

    group_pledge.save();

    return false;
  },

  _successSaveCb: function(group_pledge) {
    var pledge_id = group_pledge.get('id');
    var person_id = group_pledge.get('person_id');
    var el = $('li.follower').find('a.add[data-person_id="'+person_id+'"]');

    el.removeClass('add')
      .addClass('added')
      .attr('data-pledge_id', pledge_id) // just to be sure...
      .data('pledge_id', pledge_id);
  },

  removeFromGroup: function(evt) {
    var el = $(evt.currentTarget);

    var group_pledge = new app.models.GroupPledge({
      'id': el.data('pledge_id')
    });
    group_pledge.on('sync', this._successDestroyCb, this);
    group_pledge.on('error', function(group_pledge) {
      this._displayError('group_dropdown.error_remove', el);
    }, this);

    group_pledge.destroy();

    return false;
  },

  _successDestroyCb: function(group_pledge) {
    var pledge_id = group_pledge.get('id');
    var el = $('li.follower').find('a.added[data-pledge_id="'+pledge_id+'"]');

    el.removeClass('added')
      .addClass('add')
      .removeAttr('data-pledge_id')
      .removeData('pledge_id');
  },

  _displayError: function(msg_id, follower_el) {
    var name = $('li.follower')
                 .has(follower_el)
                 .find('h4.name')
                 .text();
    var msg = Lygneo.I18n.t(msg_id, { 'name': name });
    Lygneo.page.flashMessages.render({ 'success':false, 'notice':msg });
  }
});

$(function() {
  var follower_groups_box = new app.tmp.FollowerGroupsBox();
});

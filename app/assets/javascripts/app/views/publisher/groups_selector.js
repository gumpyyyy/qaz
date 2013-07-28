/*   Copyright (c) 2010-2012, Lygneo Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

(function(){
  // mixin-object, used in conjunction with the publisher to provide the
  // functionality for selecting groups
  app.views.PublisherGroupsSelector = {

    // event handler for group selection
    toggleGroup: function(evt) {
      var el = $(evt.target);
      var btn = el.parent('.dropdown').find('.button');

      // visually toggle the group selection
      if( el.is('.radio') ) {
        GroupsDropdown.toggleRadio(el);
      } else {
        GroupsDropdown.toggleCheckbox(el);
      }

      // update the selection summary
      this._updateGroupsNumber(el);

      this._updateSelectedGroupIds();
    },

    updateGroupsSelector: function(ids){
      var el = this.$("ul.dropdown_list");
      this.$('.dropdown_list > li').each(function(){
        var el = $(this);
        var groupId = el.data('group_id');
        if (_.contains(ids, groupId)) {
          el.addClass('selected');
        }
        else {
          el.removeClass('selected');
        }
      });

      this._updateGroupsNumber(el);
      this._updateSelectedGroupIds();
    },

    // take care of the form fields that will indicate the selected groups
    _updateSelectedGroupIds: function() {
      var self = this;

      // remove previous selection
      this.$('input[name="group_ids[]"]').remove();

      // create fields for current selection
      this.$('.dropdown .dropdown_list li.selected').each(function() {
        var el = $(this);
        var groupId = el.data('group_id');

        self._addHiddenGroupInput(groupId);

        // close the dropdown when a radio item was selected
        if( el.is('.radio') ) {
          el.closest('.dropdown').removeClass('active');
        }
      });
    },

    _updateGroupsNumber: function(el){
      GroupsDropdown.updateNumber(
        el.closest(".dropdown_list"),
        null,
        el.parent().find('li.selected').length,
        ''
      );
    },

    _addHiddenGroupInput: function(id) {
      var uid = _.uniqueId('group_ids_');
      this.$('.content_creation form').append(
        '<input id="'+uid+'" name="group_ids[]" type="hidden" value="'+id+'">'
      );
    }
  };
})();

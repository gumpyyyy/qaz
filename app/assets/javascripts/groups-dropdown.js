//   Copyright (c) 2010-2012, Lygneo Inc.  This file is
//   licensed under the Affero General Public License version 3 or later.  See
//   the COPYRIGHT file.

var GroupsDropdown = {
  updateNumber: function(dropdown, personId, number, inGroupClass){
    var button = dropdown.parents(".dropdown").children('.button.toggle'),
        selectedGroups = dropdown.children(".selected").length,
        allGroups = dropdown.children().length,
        replacement;

    if (number == 0) {
      button.removeClass(inGroupClass);
      if( dropdown.closest('#publisher').length ) {
        replacement = Lygneo.I18n.t("group_dropdown.select_groups");
      } else {
        replacement = Lygneo.I18n.t("group_dropdown.add_to_group");
        /* flash message prompt */
        var message = Lygneo.I18n.t("group_dropdown.stopped_sharing_with", {name: dropdown.data('person-short-name')});
        Lygneo.page.flashMessages.render({success: true, notice: message});
      }
    }else if (selectedGroups == allGroups) {
      replacement = Lygneo.I18n.t('group_dropdown.all_groups');
    }else if (number == 1) {
      button.addClass(inGroupClass);
      replacement = dropdown.find(".selected").first().text();
      /* flash message prompt */
      if( dropdown.closest('#publisher').length == 0 ) {
        var message = Lygneo.I18n.t("group_dropdown.started_sharing_with", {name: dropdown.data('person-short-name')});
        Lygneo.page.flashMessages.render({success: true, notice: message});
      }
    }else {
      replacement = Lygneo.I18n.t('group_dropdown.toggle', { count: number.toString()})
    }

    button.text(replacement + ' ▼');
  },

  toggleCheckbox: function(check) {
    if(!check.hasClass('radio')){
      var selectedGroups = check.closest(".dropdown").find("li.radio");
      GroupsDropdown.uncheckGroup(selectedGroups);
    }

    check.toggleClass('selected');
  },

  toggleRadio: function(check) {
    var selectedGroups = check.closest(".dropdown").find("li");

    GroupsDropdown.uncheckGroup(selectedGroups);
    GroupsDropdown.toggleCheckbox(check);
  },

  uncheckGroup: function(elements){
    $.each(elements, function(index, value) {
      $(value).removeClass('selected');
    });
  }
};


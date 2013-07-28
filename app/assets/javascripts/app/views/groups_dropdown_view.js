/**
 * the groups dropdown specifies the scope of a posted status message.
 *
 * this view is part of the publisher where users are presented the options
 * 'public', 'all groups' and a list of their personal groups, for limiting
 * 'the audience of created contents.
 */
app.views.GroupsDropdown = app.views.Base.extend({
  templateName : "groups-dropdown",
  events : {
    "change .dropdown-menu input" : "setVisibility"
  },

  presenter : function(){
    var selectedGroups = this.model.get("group_ids")
      , parsedIds = _.map(selectedGroups, parseInt)

    return {
      groups : _.map(app.currentUser.get('groups'), function(group){
        return _.extend({}, group, {checked :_.include(parsedIds, group.id) })
      }),

      public :_.include(selectedGroups, "public"),
      'all-groups' :_.include(selectedGroups, "all_groups")
    }
  },

  postRenderTemplate : function(){
    if(this.model.get("group_ids")) {
      this.setDropdownText()
    } else {
      this.setVisibility({target : this.$("input[value='public']").first()})
    }
  },

  setVisibility : function(evt){
    var input = $(evt.target).closest("input")

    if(_.include(['public', 'all_groups'], input.val())) {
      this.$("input").attr("checked", false)
      input.attr("checked", "checked")
    } else {
      this.$("input.public, input.all_groups").attr("checked", false)
    }

    this.setDropdownText()
  },

  setDropdownText : function(){
    var selected = this.$("input").serializeArray()
      , text;

    switch (selected.length) {
      case 0:
        text = "Private"
        break
      case 1:
        text = selected[0].name
        break
      default:
        text = ["In", selected.length, "groups"].join(" ")
        break
    }

    $.trim(this.$(".dropdown-toggle .text").text(text))
  }
});

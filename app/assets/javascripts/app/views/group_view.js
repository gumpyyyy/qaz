app.views.Group = app.views.Base.extend({
  templateName: "group",

  tagName: "li",

  className: 'sub_nav_item',

  initialize: function(){
    if (this.model.get('selected')){
      this.$el.addClass('active');
    };
  },

  events: {
    'click a.group_selector': 'toggleGroup'
  },

  toggleGroup: function(evt){
    if (evt) { evt.preventDefault(); };
    this.$el.toggleClass('active');
    this.$el.find('.icons-check_yes_ok').toggleClass('invisible')
    this.model.toggleSelected();
    app.router.groups_stream();
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      group : this.model
    })
  }
});

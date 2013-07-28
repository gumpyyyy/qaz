app.views.GroupsList = app.views.Base.extend({
  templateName: 'groups-list',

  el: '#groups_list',

  events: {
    'click .toggle_selector' : 'toggleAll'
  },

  initialize: function(){
    this.collection.on('change', this.toggleSelector, this);
    this.collection.on('change', this.updateStreamTitle, this);
  },

  postRenderTemplate: function() {
    this.collection.each(this.appendGroup, this);
    this.$('a[rel*=facebox]').facebox();
    this.updateStreamTitle();
    this.toggleSelector();
  },

  appendGroup: function(group) {
    $("#groups_list > *:last").before(new app.views.Group({
      model: group, attributes: {'data-group_id': group.get('id')}
    }).render().el);
  },

  toggleAll: function(evt){
    if (evt) { evt.preventDefault(); };

    var groups = this.$('li:not(:last)')
    if (this.collection.allSelected()) {
      this.collection.deselectAll();
      groups.removeClass("active");
      groups.each(function(i){
        $(this).find('.icons-check_yes_ok').addClass('invisible');
      });
    } else {
      this.collection.selectAll();
      groups.addClass("active");
      groups.each(function(i){
        $(this).find('.icons-check_yes_ok').removeClass('invisible');
      });
    }

    this.toggleSelector();
    app.router.groups_stream();
  },

  toggleSelector: function(){
    var selector = this.$('a.toggle_selector');
    if (this.collection.allSelected()) {
      selector.text(Lygneo.I18n.t('group_navigation.deselect_all'));
    } else {
      selector.text(Lygneo.I18n.t('group_navigation.select_all'));
    }
  },

  updateStreamTitle: function(){
    $('.stream_title').text(this.collection.toSentence());
  }
})

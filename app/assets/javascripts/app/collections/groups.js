app.collections.Groups = Backbone.Collection.extend({
  model: app.models.Group,

  selectedGroups: function(attribute){
    return _.pluck(_.filter(this.toJSON(), function(a){
              return a.selected;
      }), attribute);
  },

  allSelected: function(){
    return this.length === _.filter(this.toJSON(), function(a){ return a.selected; }).length;
  },

  selectAll: function(){
    this.map(function(a){ a.set({ 'selected' : true })} );
  },

  deselectAll: function(){
    this.map(function(a){ a.set({ 'selected' : false })} );
  },

  toSentence: function(){
    var separator = Lygneo.I18n.t("comma") + ' ';
    return this.selectedGroups('name').join(separator).replace(/,\s([^,]+)$/, ' ' + Lygneo.I18n.t("and") + ' $1') || Lygneo.I18n.t("my_groups");
  }
})

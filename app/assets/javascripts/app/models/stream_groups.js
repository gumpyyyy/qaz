app.models.StreamGroups = app.models.Stream.extend({

  url : function(){
    return _.any(this.items.models) ? this.timeFilteredPath() : this.basePath()
  },

  initialize : function(models, options){
    var collectionClass = options && options.collection || app.collections.Posts;
    this.items = new collectionClass([], this.collectionOptions());
    this.groups_ids = options.groups_ids;
  },

  basePath : function(){
    return '/groups';
  },

  fetch: function() {
    if(this.isFetching()){ return false }
    var url = this.url();
    var ids = this.groups_ids;
    this.deferred = this.items.fetch({
        add : true,
        url : url,
        data : { 'a_ids': ids }
    }).done(_.bind(this.triggerFetchedEvents, this))
  }
});

//= require ./content_view
app.views.Comment = app.views.Content.extend({
  templateName: "comment",
  className : "comment media",

  events : function() {
    return _.extend({}, app.views.Content.prototype.events, {
      "click .comment_delete": "destroyModel"
    });
  },

  initialize : function(options){
    this.templateName = options.templateName || this.templateName
    this.model.on("change", this.render, this)
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      canRemove: this.canRemove(),
      text : app.helpers.textFormatter(this.model.get("text"), this.model)
    })
  },

  ownComment : function() {
    return app.currentUser.authenticated() && this.model.get("author").lygneo_id == app.currentUser.get("lygneo_id")
  },

  postOwner : function() {
    return  app.currentUser.authenticated() && this.model.get("parent").author.lygneo_id == app.currentUser.get("lygneo_id")
  },

  canRemove : function() {
    return app.currentUser.authenticated() && (this.ownComment() || this.postOwner())
  }
});

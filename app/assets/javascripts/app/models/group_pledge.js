/**
 * this model represents the assignment of an group to a person.
 * (only valid for the context of the current user)
 */
app.models.GroupPledge = Backbone.Model.extend({
  urlRoot: "/group_pledges"
});
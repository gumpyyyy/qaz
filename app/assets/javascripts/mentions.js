var Mentions = {
  initialize: function(mentionsInput) {
    return mentionsInput.mentionsInput(Mentions.options);
  },

  // pre-fetch the list of followers for the current user.
  // called by the initializer of the publisher, for faster ('offline')
  // execution of the filtering for mentions
  fetchFollowers : function(){
    Mentions.followers || $.getJSON("/followers", function(data) {
      Mentions.followers = Mentions.createList(data);
    });
  },

  // creates a list of mentions out of a list of followers
  // @see _followerToMention
  createList: function(followers) {
    return _.map(followers, Mentions._followerToMention);
  },

  // takes a given follower object and modifies to fit the format
  // expected by the jQuery.mentionsInput plugin.
  // @see http://podio.github.com/jquery-mentions-input/
  _followerToMention: function(follower) {
    follower.value = follower.name;
    return follower;
  },

  // default options for jQuery.mentionsInput
  // @see http://podio.github.com/jquery-mentions-input/
  options: {
    elastic: false,
    minChars: 1,

    onDataRequest: function(mode, query, callback) {
      var filteredResults = _.filter(Mentions.followers, function(item) { return item.name.toLowerCase().indexOf(query.toLowerCase()) > -1 });

      callback.call(this, filteredResults.slice(0,5));
    },

    templates: {
      mentionItemSyntax: _.template("@{<%= name %> ; <%= handle %>}")
    }
  }
};

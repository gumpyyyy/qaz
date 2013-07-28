Lygneo.Pages.FollowersIndex = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, document) {
    self.infiniteScroll = self.instantiate("InfiniteScroll",
          {donetext: Lygneo.I18n.t("infinite_scroll.no_more_followers"),});
    $('.conversation_button').tooltip({placement: 'bottom'});
  });

};

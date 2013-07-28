(function() {
  var Stream = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, stream) {
      if( Lygneo.backboneEnabled() ){ return }

      $.extend(self, {
        stream: $(stream),
        mainStream: $(stream).find('#main_stream'),
        headerTitle: $(stream).find('#group_stream_header > h3')
      });
    });

    this.globalSubscribe("stream/reloaded stream/scrolled", function() {
      self.publish("widget/ready", self.stream);
    });

    this.empty = function() {
      self.mainStream.empty();
      self.headerTitle.text(Lygneo.I18n.t('stream.no_groups'));
    };

    this.setHeaderTitle = function(newTitle) {
      self.headerTitle.text(newTitle);
    };
  };

  if(!Lygneo.backboneEnabled()) {
    Lygneo.Widgets.Stream = Stream;
  }
})();

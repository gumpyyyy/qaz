/*   Copyright (c) 2010-2011, Lygneo Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

(function() {
  var Lygneo = {
    Pages: {},
    Widgets: {}
  };

  Lygneo.EventBroker = {
    extend: function(Klass) {
      var whatToExtend = (typeof Klass === "function") ? Klass.prototype : Klass;

      $.extend(whatToExtend, {
	      eventsContainer: $({}),
        publish: function(eventName, args) {
          var eventNames = eventName.split(" ");

          for(eventName in eventNames) {
            this.eventsContainer.trigger(eventNames[eventName], args);
          }
        },
        subscribe: function(eventName, callback, context) {
          var eventNames = eventName.split(" ");

          for(eventName in eventNames) {
            this.eventsContainer.bind(eventNames[eventName], $.proxy(callback, context));
          }
        }
      });

      return whatToExtend;
    }
  };

  Lygneo.BaseWidget = {
    instantiate: function(Widget, element) {
      $.extend(Lygneo.Widgets[Widget].prototype, Lygneo.EventBroker.extend(Lygneo.BaseWidget));

      var widget = new Lygneo.Widgets[Widget](),
        args = Array.prototype.slice.call(arguments, 1);

      widget.publish("widget/ready", args);

      return widget;
    },

    globalSubscribe: function(eventName, callback, context) {
      Lygneo.page.subscribe(eventName, callback, context);
    },

    globalPublish: function(eventName, args) {
      Lygneo.page.publish(eventName, args);
    }
  };

  Lygneo.BasePage = function(body) {
    $.extend(this, Lygneo.BaseWidget);
    $.extend(this, {
      backToTop: this.instantiate("BackToTop", body.find("#back-to-top")),
      directionDetector: this.instantiate("DirectionDetector"),
      events: function() { return Lygneo.page.eventsContainer.data("events"); },
      flashMessages: this.instantiate("FlashMessages"),
      header: this.instantiate("Header", body.find("header")),
      timeAgo: this.instantiate("TimeAgo")
    });
  };

  Lygneo.instantiatePage = function() {
    if (typeof Lygneo.Pages[Lygneo.Page] === "undefined") {
      Lygneo.page = Lygneo.EventBroker.extend(Lygneo.BaseWidget);
    } else {
      var Page = Lygneo.Pages[Lygneo.Page];
      $.extend(Page.prototype, Lygneo.EventBroker.extend(Lygneo.BaseWidget));

      Lygneo.page = new Page();
    }

    if(!$.mobile)//why does this need this?
      $.extend(Lygneo.page, new Lygneo.BasePage($(document.body)));
    Lygneo.page.publish("page/ready", [$(document.body)])
  };

  // temp hack to check if backbone is enabled for the page
  Lygneo.backboneEnabled = function(){
    return window.app && window.app.stream !== undefined;
  }

  window.Lygneo = Lygneo;
})();


$(Lygneo.instantiatePage);

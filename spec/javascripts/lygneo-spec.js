/*   Copyright (c) 2010-2011, Lygneo Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

describe("Lygneo", function() {
  describe("EventBroker", function() {
    describe("extend", function() {
      var klass;
      beforeEach(function() {
        klass = new function() {
        };
      });

      it("should add a subscribe method to the class", function() {
        Lygneo.EventBroker.extend(klass);

        expect(typeof klass.subscribe).toEqual("function");
      });

      it("should add a publish method to the class", function() {
        Lygneo.EventBroker.extend(klass);

        expect(typeof klass.publish).toEqual("function");
      });

      it("should add an events container to the class", function() {
        Lygneo.EventBroker.extend(klass);

        expect(typeof klass.eventsContainer).toEqual("object");
      });

      it("knows what to extend", function() {
        var Klass = function() {
        };

        Lygneo.EventBroker.extend(Klass);

        expect(typeof Klass.prototype.publish).toEqual("function");
        expect(typeof Klass.prototype.subscribe).toEqual("function");
        expect(typeof Klass.prototype.eventsContainer).toEqual("object");
      });

      it("adds basic pub/sub functionality to an object", function() {
        Lygneo.EventBroker.extend(klass);
        var called = false;

        klass.subscribe("events/event", function() {
          called = true;
        });

        klass.publish("events/event");

        expect(called).toBeTruthy();
      });

      describe("subscribe", function() {
        it("will subscribe to multiple events", function() {
          var firstEventCalled = false,
                  secondEventCalled = false
          events = Lygneo.EventBroker.extend({});

          events.subscribe("first/event second/event", function() {
            if (firstEventCalled) {
              secondEventCalled = true;
            } else {
              firstEventCalled = true;
            }
          });

          events.publish("first/event second/event");

          expect(firstEventCalled).toBeTruthy();
          expect(secondEventCalled).toBeTruthy();
        });
      });

      describe("publish", function() {
        it("will publish multiple events", function() {
          var firstEventCalled = false,
                  secondEventCalled = false
          events = Lygneo.EventBroker.extend({});

          events.subscribe("first/event second/event", function() {
            if (firstEventCalled) {
              secondEventCalled = true;
            } else {
              firstEventCalled = true;
            }
          });

          events.publish("first/event second/event");

          expect(firstEventCalled).toBeTruthy();
          expect(secondEventCalled).toBeTruthy();
        });
      });
    });
  });

  describe("BaseWidget", function() {
    var MyWidget = function() {
      var self = this;
      this.ready = false;

      this.subscribe("widget/ready", function(evt, element) {
        self.ready = true;
        self.element = element;
      });
    };

    beforeEach(function() {
      Lygneo.Widgets.MyWidget = MyWidget;
    });

    describe("instantiate", function() {
      it("instantiates a widget and calls widget/ready with an element", function() {
        var element = $("foo bar baz"),
          myWidget = Lygneo.BaseWidget.instantiate("MyWidget", element);

        expect(myWidget.ready).toBeTruthy();
        expect(myWidget.element.selector).toEqual(element.selector);
      });
    });

    describe("globalSubscribe", function() {
      it("calls subscribe on Lygneo.page", function() {
        var spy = spyOn(Lygneo.page, "subscribe");

        var myWidget = Lygneo.BaseWidget.instantiate("MyWidget", null);
        myWidget.globalSubscribe("myEvent", $.noop);

        expect(spy).toHaveBeenCalled();
      });
    });

    describe("globalPublish", function() {
      it("calls publish on Lygneo.Page", function() {
        var spy = spyOn(Lygneo.page, "publish");

        var myWidget = Lygneo.BaseWidget.instantiate("MyWidget", null);
        myWidget.globalPublish();

        expect(spy).toHaveBeenCalled();
      });
    });
  });
});

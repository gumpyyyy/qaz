/*   Copyright (c) 2010-2011, Lygneo Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

describe("Lygneo", function() {
  describe("widgets", function() {
    describe("i18n", function() {
      var locale = {namespace: {
          message: "hey",
          template: "<%= myVar %>",
          otherNamespace: {
            message: "hello from another namespace",
            otherMessage: {
              zero: "none",
              one: "just one",
              few: "just a few",
              many: "way too many",
              other: "what?"
            }
          }
        }
      };

      describe("loadLocale", function() {
        it("sets the class's locale variable", function() {
          Lygneo.I18n.loadLocale(locale);

          expect(Lygneo.I18n.locale).toEqual(locale);
        });
      });

      describe("t", function() {
        var translation;
        beforeEach(function() { Lygneo.I18n.loadLocale(locale); });

        it("returns the specified translation", function() {
          translation = Lygneo.I18n.t("namespace.message");

          expect(translation).toEqual("hey");
        });

        it("will go through a infinitely deep object", function() {
         translation = Lygneo.I18n.t("namespace.otherNamespace.message");

         expect(translation).toEqual("hello from another namespace");
        });

        it("can render a mustache template", function() {
          translation = Lygneo.I18n.t("namespace.template", { myVar: "it works!" });

          expect(translation).toEqual("it works!");
        });

        it("returns an empty string if the translation is not found", function() {
          expect(Lygneo.I18n.t("missing.locale")).toEqual("");
        });
      });
    });
  });
});

describe("Lygneo.Widgets.Search", function() {
    describe("parse", function() {
        it("escapes a persons name", function() {
            $("#jasmine_content").html('<form action="#" id="searchForm"></form>');

            var search = Lygneo.BaseWidget.instantiate("Search", $("#jasmine_content > #searchForm"));
            var person = {"name": "</script><script>alert('xss');</script"};
            result = search.parse([$.extend({}, person)]);
            expect(result[0].data.name).toNotEqual(person.name);
        });
    });
});

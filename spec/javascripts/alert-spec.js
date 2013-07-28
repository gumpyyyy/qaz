describe("Lygneo.Alert", function() {
  beforeEach(function() {
    spec.loadFixture("groups_index");

    $(document).trigger("close.facebox");
  });

  afterEach(function() {
    $("#facebox").remove();

  });


  describe("on widget ready", function() {
    it("should remove #lygneo_alert on close.facebox", function() {
      Lygneo.Alert.show("YEAH", "YEAHH");
      expect($("#lygneo_alert").length).toEqual(1);
      $(document).trigger("close.facebox");
      expect($("#lygneo_alert").length).toEqual(0);
    });
  });

  describe("alert", function() {
    it("should render a mustache template and append it the body", function() {
      Lygneo.Alert.show("YO", "YEAH");
      expect($("#lygneo_alert").length).toEqual(1);
      $(document).trigger("close.facebox");
    });
  });
});

describe("app.models.Group", function(){
  describe("#toggleSelected", function(){
    it("should select the group", function(){
      this.group = new app.models.Group({ name: 'John Doe', selected: false });
      this.group.toggleSelected();
      expect(this.group.get("selected")).toBeTruthy();
    });

    it("should deselect the group", function(){
      this.group = new app.models.Group({ name: 'John Doe', selected: true });
      this.group.toggleSelected();
      expect(this.group.get("selected")).toBeFalsy();
    });
  });
});

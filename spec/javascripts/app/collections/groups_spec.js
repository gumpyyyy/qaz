describe("app.collections.Groups", function(){
  beforeEach(function(){
    Lygneo.I18n.loadLocale({
      'and' : "and",
      'comma' : ",",
      'my_groups' : "My Groups"
    });
    var my_groups = [{ name: 'Work',          selected: true  },
                      { name: 'Friends',       selected: false },
                      { name: 'Acquaintances', selected: false }]
    this.groups = new app.collections.Groups(my_groups);
  });

  describe("#selectAll", function(){
    it("selects every group in the collection", function(){
      this.groups.selectAll();
      this.groups.each(function(group){
        expect(group.get('selected')).toBeTruthy();
      });
    });
  });

  describe("#deselectAll", function(){
    it("deselects every group in the collection", function(){
      this.groups.deselectAll();
      this.groups.each(function(group){
        expect(group.get('selected')).toBeFalsy();
      });
    });
  });

  describe("#allSelected", function(){
    it("returns true if every group is selected", function(){
      this.groups.at(1).set('selected', true);
      this.groups.at(2).set('selected', true);
      expect(this.groups.allSelected()).toBeTruthy();
    });

    it("returns false if at least one group is not selected", function(){
      expect(this.groups.allSelected()).toBeFalsy();
    });
  });

  describe("#toSentence", function(){
    describe('without groups', function(){
      beforeEach(function(){
        this.groups = new app.collections.Groups({ name: 'Work', selected: false })
        spyOn(this.groups, 'selectedGroups').andCallThrough();
      });

      it("returns the name of the group", function(){
        expect(this.groups.toSentence()).toEqual('My Groups');
        expect(this.groups.selectedGroups).toHaveBeenCalled();
      });
    });

    describe("with one group", function(){
      beforeEach(function(){
        this.groups = new app.collections.Groups({ name: 'Work', selected: true })
        spyOn(this.groups, 'selectedGroups').andCallThrough();
      });

      it("returns the name of the group", function(){
        expect(this.groups.toSentence()).toEqual('Work');
        expect(this.groups.selectedGroups).toHaveBeenCalled();
      });
    });

    describe("with three group", function(){
      it("returns the name of the selected group", function(){
        expect(this.groups.toSentence()).toEqual('Work');
      });

      it("returns the names of the two selected groups", function(){
        this.groups.at(1).set('selected', true);
        expect(this.groups.toSentence()).toEqual('Work and Friends');
      });

      it("returns the names of the selected groups in a comma-separated sentence", function(){
        this.groups.at(1).set('selected', true);
        this.groups.at(2).set('selected', true);
        expect(this.groups.toSentence()).toEqual('Work, Friends and Acquaintances');
      });
    });
  });

  describe("#selectedGroups", function(){
    describe("by name", function(){
      it("returns the names of the selected groups", function(){
        expect(this.groups.selectedGroups('name')).toEqual(["Work"]);
      });
    });
  });
});

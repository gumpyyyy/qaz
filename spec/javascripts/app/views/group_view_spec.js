describe("app.views.Group", function(){
  beforeEach(function(){
    this.group = new app.models.Group({ name: 'Acquaintances', selected: true });
    this.view = new app.views.Group({ model: this.group });
  });

  describe("render", function(){
    beforeEach(function(){
      this.view.render();
    });

    it('should show the group selected', function(){
      expect(this.view.$el.hasClass('active')).toBeTruthy();
    });

    it('should show the name of the group', function(){
      expect(this.view.$('a.group_selector').text()).toMatch('Acquaintances');
    });

    describe('selecting groups', function(){
      beforeEach(function(){
        app.router = new app.Router();
        spyOn(app.router, 'groups_stream');
        spyOn(this.view, 'toggleGroup').andCallThrough();
        this.view.delegateEvents();
      });

      it('it should deselect the group', function(){
        this.view.$('a.group_selector').trigger('click');
        expect(this.view.toggleGroup).toHaveBeenCalled();
        expect(this.view.$el.hasClass('active')).toBeFalsy();
        expect(app.router.groups_stream).toHaveBeenCalled();
      });

      it('should call #toggleSelected on the model', function(){
        spyOn(this.group, 'toggleSelected');
        this.view.$('a.group_selector').trigger('click');
        expect(this.group.toggleSelected).toHaveBeenCalled();
      });
    });
  });
});

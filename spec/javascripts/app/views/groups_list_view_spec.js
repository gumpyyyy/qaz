describe("app.views.GroupsList", function(){
  beforeEach(function(){
    setFixtures('<ul id="groups_list"></ul>');
    Lygneo.I18n.loadLocale({ group_navigation : {
      'select_all' : 'Select all',
      'deselect_all' : 'Deselect all'
    }});

    var groups  = [{ name: 'Work',          selected: true  },
                   { name: 'Friends',       selected: false },
                   { name: 'Acquaintances', selected: false }];
    this.groups = new app.collections.Groups(groups);
    this.view    = new app.views.GroupsList({ collection: this.groups });
  });

  describe('rendering', function(){
    beforeEach(function(){
      this.view.render();
    });

    it('should show the corresponding groups selected', function(){
      expect(this.view.$('.active').length).toBe(1);
      expect(this.view.$('.active > .group_selector').text()).toMatch('Work');
    });

    it('should show all the groups', function(){
      var group_selectors = this.view.$('.group_selector');
      expect(group_selectors.length).toBe(3)
      expect(group_selectors[0].text).toMatch('Work');
      expect(group_selectors[1].text).toMatch('Friends');
      expect(group_selectors[2].text).toMatch('Acquaintances');
    });

    it('should show \'Select all\' link', function(){
      expect(this.view.$('.toggle_selector').text()).toMatch('Select all');
    });

    describe('selecting groups', function(){
      context('selecting all groups', function(){
        beforeEach(function(){
          app.router = new app.Router();
          spyOn(app.router, 'groups_stream');
          spyOn(this.view, 'toggleAll').andCallThrough();
          spyOn(this.view, 'toggleSelector').andCallThrough();
          this.view.delegateEvents();
          this.view.$('.toggle_selector').click();
        });

        it('should show all the groups selected', function(){
          expect(this.view.toggleAll).toHaveBeenCalled();
          expect(this.view.$('li.active').length).toBe(3);
        });

        it('should show \'Deselect all\' link', function(){
          expect(this.view.toggleSelector).toHaveBeenCalled();
          expect(this.view.$('.toggle_selector').text()).toMatch('Deselect all');
        });
      });
    });
  });
});

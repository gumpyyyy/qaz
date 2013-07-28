
describe("app.views.GroupPledge", function(){
  beforeEach(function() {
    // mock a dummy group dropdown
    this.person = factory.author({name: "My Name"});
    spec.content().html(
      '<div class="group_pledge dropdown">'+
      '  <div class="button toggle">The Button</div>'+
      '  <ul class="dropdown_list" data-person-short-name="'+this.person.name+'" data-person_id="'+this.person.id+'">'+
      '    <li data-group_id="10">Group 10</li>'+
      '    <li data-pledge_id="99" data-group_id="11" class="selected">Group 11</li>'+
      '    <li data-group_id="12">Group 12</li>'+
      '  </ul>'+
      '</div>'
    );

    this.view = new app.views.GroupPledge();
  });

  it('attaches to the group selector', function(){
    spyOn($.fn, 'on');
    view = new app.views.GroupPledge();

    expect($.fn.on).toHaveBeenCalled();
  });

  context('adding to groups', function() {
    beforeEach(function() {
      this.newGroup = spec.content().find('li:eq(0)');
      this.newGroupId = 10;
    });

    it('calls "addPledge"', function() {
       spyOn(this.view, "addPledge");
       this.newGroup.trigger('click');

       expect(this.view.addPledge).toHaveBeenCalledWith(this.person.id, this.newGroupId);
    });

    it('tries to create a new GroupPledge', function() {
      spyOn(app.models.GroupPledge.prototype, "save");
      this.view.addPledge(1, 2);

      expect(app.models.GroupPledge.prototype.save).toHaveBeenCalled();
    });

    it('displays an error when it fails', function() {
      spyOn(this.view, "_displayError");
      spyOn(app.models.GroupPledge.prototype, "save").andCallFake(function() {
        this.trigger('error');
      });

      this.view.addPledge(1, 2);

      expect(this.view._displayError).toHaveBeenCalledWith('group_dropdown.error');
    });
  });

  context('removing from groups', function(){
    beforeEach(function() {
      this.oldGroup = spec.content().find('li:eq(1)');
      this.oldPledgeId = 99;
    });

    it('calls "removePledge"', function(){
      spyOn(this.view, "removePledge");
      this.oldGroup.trigger('click');

      expect(this.view.removePledge).toHaveBeenCalledWith(this.oldPledgeId);
    });

    it('tries to destroy an GroupPledge', function() {
      spyOn(app.models.GroupPledge.prototype, "destroy");
      this.view.removePledge(1);

      expect(app.models.GroupPledge.prototype.destroy).toHaveBeenCalled();
    });

    it('displays an error when it fails', function() {
      spyOn(this.view, "_displayError");
      spyOn(app.models.GroupPledge.prototype, "destroy").andCallFake(function() {
        this.trigger('error');
      });

      this.view.removePledge(1);

      expect(this.view._displayError).toHaveBeenCalledWith('group_dropdown.error_remove');
    });
  });

  context('summary text in the button', function() {
    beforeEach(function() {
      this.btn = spec.content().find('div.button.toggle');
      this.btn.text(""); // reset
      this.view.dropdown = spec.content().find('ul.dropdown_list');
    });

    it('shows "no groups" when nothing is selected', function() {
      spec.content().find('li[data-group_id]').removeClass('selected');
      this.view.updateSummary();

      expect(this.btn.text()).toContain(Lygneo.I18n.t('group_dropdown.toggle.zero'));
    });

    it('shows "all groups" when everything is selected', function() {
      spec.content().find('li[data-group_id]').addClass('selected');
      this.view.updateSummary();

      expect(this.btn.text()).toContain(Lygneo.I18n.t('group_dropdown.all_groups'));
    });

    it('shows the name of the selected group ( == 1 )', function() {
      var list = spec.content().find('li[data-group_id]');
      list.removeClass('selected'); // reset
      list.eq(1).addClass('selected');
      this.view.updateSummary();

      expect(this.btn.text()).toContain(list.eq(1).text());
    });

    it('shows the number of selected groups ( > 1)', function() {
      var list = spec.content().find('li[data-group_id]');
      list.removeClass('selected'); // reset
      $([list.eq(1), list.eq(2)]).addClass('selected');
      this.view.updateSummary();

      expect(this.btn.text()).toContain(Lygneo.I18n.t('group_dropdown.toggle', { 'count':2 }));
    });
  });
});

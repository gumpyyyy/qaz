/**
 * this view lets the user (de-)select group pledges in the context
 * of another users profile or the follower page.
 *
 * updates to the list of groups are immediately propagated to the server, and
 * the results are dislpayed as flash messages.
 */
app.views.GroupPledge = Backbone.View.extend({

  initialize: function() {
    // attach event handler, removing any previous instances
    var selector = '.dropdown.group_pledge .dropdown_list > li';
    $('body')
      .off('click', selector)
      .on('click', selector, _.bind(this._clickHandler, this));

    this.list_item = null;
    this.dropdown  = null;
  },

  // decide what to do when clicked
  //   -> addPledge
  //   -> removePledge
  _clickHandler: function(evt) {
    this.list_item = $(evt.target);
    this.dropdown  = this.list_item.parent();

    this.list_item.addClass('loading');

    if( this.list_item.is('.selected') ) {
      var pledge_id = this.list_item.data('pledge_id');
      this.removePledge(pledge_id);
    } else {
      var group_id = this.list_item.data('group_id');
      var person_id = this.dropdown.data('person_id');
      this.addPledge(person_id, group_id);
    }

    return false; // stop the event
  },

  // return the (short) name of the person associated with the current dropdown
  _name: function() {
    return this.dropdown.data('person-short-name');
  },

  // create a pledge for the given person in the given group
  addPledge: function(person_id, group_id) {
    var group_pledge = new app.models.GroupPledge({
      'person_id': person_id,
      'group_id': group_id
    });

    group_pledge.on('sync', this._successSaveCb, this);
    group_pledge.on('error', function() {
      this._displayError('group_dropdown.error');
    }, this);

    group_pledge.save();
  },

  _successSaveCb: function(group_pledge) {
    var group_id = group_pledge.get('group_id');
    var pledge_id = group_pledge.get('id');
    var li = this.dropdown.find('li[data-group_id="'+group_id+'"]');

    // the user didn't have this person in any groups before, congratulate them
    // on their newly found friendship ;)
    if( this.dropdown.find('li.selected').length == 0 ) {
      var msg = Lygneo.I18n.t('group_dropdown.started_sharing_with', { 'name': this._name() });
      Lygneo.page.flashMessages.render({ 'success':true, 'notice':msg });
    }

    li.attr('data-pledge_id', pledge_id) // just to be sure...
      .data('pledge_id', pledge_id)
      .addClass('selected');

    this.updateSummary();
    this._done();
  },

  // show an error flash msg
  _displayError: function(msg_id) {
    this._done();
    this.dropdown.removeClass('active'); // close the dropdown

    var msg = Lygneo.I18n.t(msg_id, { 'name': this._name() });
    Lygneo.page.flashMessages.render({ 'success':false, 'notice':msg });
  },

  // remove the pledge with the given id
  removePledge: function(pledge_id) {
    var group_pledge = new app.models.GroupPledge({
      'id': pledge_id
    });

    group_pledge.on('sync', this._successDestroyCb, this);
    group_pledge.on('error', function() {
      this._displayError('group_dropdown.error_remove');
    }, this);

    group_pledge.destroy();
  },

  _successDestroyCb: function(group_pledge) {
    var pledge_id = group_pledge.get('id');
    var li = this.dropdown.find('li[data-pledge_id="'+pledge_id+'"]');

    li.removeAttr('data-pledge_id')
      .removeData('pledge_id')
      .removeClass('selected');

    // we just removed the last group, inform the user with a flash message
    // that he is no longer sharing with that person
    if( this.dropdown.find('li.selected').length == 0 ) {
      var msg = Lygneo.I18n.t('group_dropdown.stopped_sharing_with', { 'name': this._name() });
      Lygneo.page.flashMessages.render({ 'success':true, 'notice':msg });
    }

    this.updateSummary();
    this._done();
  },

  // cleanup tasks after group selection
  _done: function() {
    if( this.list_item ) {
      this.list_item.removeClass('loading');
    }
  },

  // refresh the button text to reflect the current group selection status
  updateSummary: function() {
    var btn = this.dropdown.parents('div.group_pledge').find('.button.toggle');
    var groups_cnt = this.dropdown.find('li.selected').length;
    var txt;

    if( groups_cnt == 0 ) {
      btn.removeClass('in_groups');
      txt = Lygneo.I18n.t('group_dropdown.toggle.zero');
    } else {
      btn.addClass('in_groups');
      txt = this._pluralSummaryTxt(groups_cnt);
    }

    btn.text(txt + ' ▼');
  },

  _pluralSummaryTxt: function(cnt) {
    var all_groups_cnt = this.dropdown.find('li').length;

    if( cnt == 1 ) {
      return this.dropdown.find('li.selected').first().text();
    }

    if( cnt == all_groups_cnt ) {
      return Lygneo.I18n.t('group_dropdown.all_groups');
    }

    return Lygneo.I18n.t('group_dropdown.toggle', { 'count':cnt.toString() });
  }
});

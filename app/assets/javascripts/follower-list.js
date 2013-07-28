/*   Copyright (c) 2010-2011, Lygneo Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

var List = {
  initialize: function() {
    $(".follower_list_search").live("keyup", function(e) {
      var search = $(this);
      var list   = $(".followers", ".searchable");
      var query  = new RegExp(search.val(),'i');

      $("> .follower", list).each( function(idx, element) {
        element = $(element);
        if( !element.find(".name").text().match(query) ) {
          element.addClass('hidden');
        } else {
          element.removeClass('hidden');
        }
      });
    });
  },

  disconnectUser: function(follower_id){
    $.ajax({
        url: "/followers/" + follower_id,
        type: "DELETE",
        success: function(){
          if( $('.searchable').length == 1){
              $('.searchable .follower[data-follower_id='+follower_id+']').fadeOut(200);
          } else if($('#groups_list').length == 1) {
            $.facebox.close();
          };
        }
    });
  },

  runDelayedSearch: function( searchTerm ) {
    $.getJSON('/people/refresh_search',
      { q: searchTerm },
      List.handleSearchRefresh
    );
  },

  handleSearchRefresh: function( data ) {
    var streamEl = $("#people_stream.stream");
    var string = data.search_html || $("<p>", {
        text : Lygneo.I18n.t("people.not_found")
      });

    streamEl.html(string);
  },

  startSearchDelay: function (theSearch) {
    setTimeout( "List.runDelayedSearch('" + theSearch + "')", 10000);
  }

};

$(document).ready(function() {
  $('.added').bind('ajax:loading', function() {
    var $this = $(this);

    $this.addClass('disabled');
    $this.fadeTo(200,0.4);
  });

  $('.added').bind('hover',
    function() {
      var $this = $(this)
      $this.addClass("remove");
      $this.children("img").attr("src","/images/icons/monotone_close_exit_delete.png");
    },

    function() {
      var $this = $(this)
      $this.removeClass("remove");
      $this.children("img").attr("src","/images/icons/monotone_check_yes.png");
  });

  List.initialize();
});

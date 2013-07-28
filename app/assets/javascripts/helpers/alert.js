Lygneo.Alert = {
  faceboxTemplate:
    '<div id="lygneo_alert">' +
      '<div class="span-12 last">' +
        '<div id="facebox_header">' +
          '<h4>' +
          '<%= title %>' +
          '</h4>' +
        '</div>' +
        '<%= content %>' +
      '</div>' +
    '</div>',

  show: function(title, content) {
    $(_.template(this.faceboxTemplate, {
      title: title,
    content: content
    })).appendTo(document.body);

    $.facebox({
      div: "#lygneo_alert"
    }, "lygneo_alert");
  }
};

$(function() {
  $(document).bind("close.facebox", function() {
    $("#lygneo_alert").remove();
  });
});

var Notification = (function() {
  "use strict";

  var elem,
    hideHandler,
    that = {};

  that.init = function(selector) {
    elem = $(selector);
  };

  that.show = function(text) {
    clearTimeout(hideHandler);

    elem.find("span").html(text);
    elem.delay(200).fadeIn().delay(4000).fadeOut();
  };

  that.error = function(text) {
    clearTimeout(hideHandler);

    elem.removeClass("alert-info").addClass("alert-danger")
    elem.find("span").html(text);
    elem.delay(200).fadeIn().delay(4000).fadeOut();
  };

  that.info = function(text) {
    clearTimeout(hideHandler);

    elem.removeClass("alert-danger").addClass("alert-info")
    elem.find("span").html(text);
    elem.delay(200).fadeIn().delay(4000).fadeOut();
  };

  return that;
}());
